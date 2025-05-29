import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  // Function to launch WhatsApp with a pre-filled message
  Future<void> _launchWhatsApp(BuildContext context) async {
    final String phoneNumber = "+201147521742";
    final String message =
        "Hello, I'm interested in purchasing the course: ${course.title} priced at \$${course.price}.";
    final String url =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 0.40.sh, // 25% of screen height
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.r),
                  bottomRight: Radius.circular(40.r),
                ),
                child: course.courseImage != null
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
              ),
            ),
            // Course details container
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow("Description",
                        course.description ?? "No description available"),
                    _buildInfoRow("Price", "\$${course.price}"),
                    _buildInfoRow("Category", course.category ?? "N/A"),
                    _buildInfoRow("Instructor", course.instructor ?? "N/A"),
                    _buildInfoRow(
                      "Created At",
                      DateFormat('dd MMM yyyy')
                          .format(course.createdAt.toLocal()),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: MainButton(
                        text: "Buy Course",
                        onTap: () => _launchWhatsApp(context),
                        backGroundColor: primaryColor,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
