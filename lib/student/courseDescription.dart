import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/instructor/courses_Videos.dart';
import 'package:education_app/student/enrollment_states.dart';

import 'package:education_app/student/materials.dart';
import 'package:education_app/student/studentCubit.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enrollcubit.dart';

class StudentCourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const StudentCourseDetailsScreen({Key? key, required this.course})
      : super(key: key);

  @override
  State<StudentCourseDetailsScreen> createState() =>
      _StudentCourseDetailsScreenState();
}

class _StudentCourseDetailsScreenState
    extends State<StudentCourseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentCubit()..checkEnrollment(widget.course),
      child: BlocListener<EnrollmentCubit, EnrollmentState>(
        listener: (context, state) {
          if (state is EnrollmentForbidden) {
            _showPurchaseDialog(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      _buildCourseDescription(),
                      _buildContentAccessSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0.4.sh,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'course-${widget.course.id}',
          child: Stack(
            children: [
              widget.course.courseImage != null
                  ? Container(
                      width: double.infinity,
                      child: Image.network(
                        "$baseUrlKey/${widget.course.courseImage!}",
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16.h,
                left: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        widget.course.category ??
                            'course_details.general_category'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.attach_money, 'course_details.price'.tr(),
                  '\LE ${widget.course.price}'),
              Divider(height: 1, color: Colors.grey[300]),
              _buildInfoItem(
                  Icons.calendar_today,
                  'course_details.created'.tr(),
                  DateFormat('MMM yyyy').format(widget.course.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'course_details.description_title'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.course.description ?? 'course_details.no_description'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContentAccessSection(BuildContext context) {
    return BlocBuilder<EnrollmentCubit, EnrollmentState>(
      builder: (context, state) {
        if (state is EnrollmentLoading) {
          return Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 20),
                Text(
                  'course_details.checking_access'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is EnrollmentSuccess) {
          return _buildContentButtons(context);
        }

        // Show subscribe button for EnrollmentForbidden or other states
        return _buildSubscribeButton(context);
      },
    );
  }

  Widget _buildContentButtons(BuildContext context) {
    return Column(
      children: [
        Gap(10),
        Text(
          'course_details.access_content'.tr(),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.video_library,
                label: "course_details.videos".tr(),
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideosScreen(
                                courseId: widget.course.id,
                                courseTitle: widget.course.title,
                              )));
                },
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.insert_drive_file,
                label: "course_details.files".tr(),
                color: Colors.purple,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentMaterialsScreen(
                                courseId: widget.course.id,
                              )));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.orange),
          ),
          child: Column(
            children: [
              Icon(Icons.lock, size: 40.sp, color: Colors.orange),
              SizedBox(height: 12.h),
              Text(
                'course_details.premium_locked'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'course_details.subscribe_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        MainButton(
          text: 'course_details.subscribe_now'.tr(),
          onTap: () => _launchWhatsApp(context),
          backGroundColor: primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        // elevation: 4,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const Gap(8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final String phoneNumber = "+201146607873";
    final String message =
        "مرحبًا، أرغب بالتسجيل في دورة \"${widget.course.title}\" والتي يبلغ سعرها ${widget.course.price} ج.م. هل يمكنني معرفة خطوات التسجيل؟"
            .tr(args: [widget.course.title, widget.course.price.toString()]);
    final String url =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('course_details.whatsapp_error'.tr())),
      );
    }
  }

  void _showPurchaseDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 50,
                color: primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'course_details.premium_content'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'course_details.not_now'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsApp(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'course_details.purchase'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
