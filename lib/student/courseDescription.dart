import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/instructor/Materilas.dart';
import 'package:education_app/instructor/courses_Videos.dart';
import 'package:education_app/student/materials.dart';
import 'package:education_app/student/studentCubit.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check enrollment status when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCubit>().checkEnrollment(course);
    });

    return BlocListener<StudentCubit, CourseState>(
      listener: (context, state) {
        if (state is CourseEnrollmentForbidden &&
            state.course.id == course.id) {
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
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    _buildInfoCard(),
                    SizedBox(height: 24.h),
                    _buildCourseDescription(),
                    SizedBox(height: 24.h),
                    _buildContentAccessSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0.4.sh,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'course-${course.id}',
          child: Stack(
            children: [
              course.courseImage != null
                  ? Image.network(
                      course.courseImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
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
                        course.category ?? 'General',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 24.sp,
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
            size: 20.sp,
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     _buildInfoItem(Icons.schedule, 'Duration', '10 Hours'),
          //     _buildInfoItem(Icons.video_library, 'Lectures', '24 Videos'),
          //     _buildInfoItem(Icons.bar_chart, 'Level', 'Intermediate'),
          //   ],divid
          // ),
          SizedBox(height: 16.h),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.attach_money, 'Price', '\$${course.price}'),
              Divider(height: 1, color: Colors.grey[300]),
              _buildInfoItem(Icons.calendar_today, 'Created',
                  DateFormat('MMM yyyy').format(course.createdAt)),
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
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
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
          'Course Description',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          course.description ?? 'No description available',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContentAccessSection(BuildContext context) {
    return BlocBuilder<StudentCubit, CourseState>(
      builder: (context, state) {
        if (state is CourseEnrollmentLoading) {
          return Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 16.h),
                Text(
                  'Checking your access...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // If user is subscribed, show content access buttons
        if (state is CourseEnrollmentSuccess && state.course.id == course.id) {
          return _buildContentButtons(context);
        }

        // If user is not subscribed, show subscription button
        return _buildSubscribeButton(context);
      },
    );
  }

  Widget _buildContentButtons(BuildContext context) {
    return Column(
      children: [
        Text(
          'Access your course content',
          style: TextStyle(
            fontSize: 18.sp,
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
                label: "Videos",
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideosScreen(
                                courseId: course.id,
                                courseTitle: course.title,
                              )));
                },
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.insert_drive_file,
                label: "Files",
                color: Colors.purple,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentMaterialsScreen(
                                courseId: course.id,
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
                'Premium Content Locked',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Subscribe to access all videos and materials for this course',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        MainButton(
          text: 'Subscribe Now',
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
        elevation: 4,
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
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final String phoneNumber = "+201147521742";
    final String message =
        "مرحبا اريد شراء كورس ${course.title} اللذي يبلغ سعره \$${course.price}.";
    final String url =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
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
                size: 60.sp,
                color: primaryColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'Premium Content',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 24.h),
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
                        'Not Now',
                        style: TextStyle(
                          fontSize: 16.sp,
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
                        'Purchase',
                        style: TextStyle(
                          fontSize: 16.sp,
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
