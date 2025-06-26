import 'dart:io';
import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/instructor/instructorHomeScreen.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

class EditCourseScreen extends StatefulWidget {
  final dynamic course;
  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController courseName;
  late TextEditingController description;
  late TextEditingController catController;
  late TextEditingController price;
  File? courseImage;
  String? initialImageUrl;

  @override
  void initState() {
    super.initState();
    courseName = TextEditingController(text: widget.course.title);
    description = TextEditingController(text: widget.course.description);
    catController = TextEditingController(text: widget.course.category);
    price = TextEditingController(text: widget.course.price.toString());
    initialImageUrl = widget.course.courseImage;
  }

  @override
  void dispose() {
    courseName.dispose();
    description.dispose();
    catController.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        courseImage = File(picked.path);
        initialImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text('edit_course.title'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: courseImage != null || initialImageUrl != null
                      ? Colors.transparent
                      : Colors.grey[300]!,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: courseImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(courseImage!, fit: BoxFit.cover),
                    )
                  : initialImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            "https://mrvet-production.up.railway.app/$initialImageUrl",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          ),
                        )
                      : _buildPlaceholderImage(),
            ),
          ),
          const Gap(24),

          // Course Name
          Text('edit_course.course_name'.tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14)),
          const Gap(8),
          _buildTextField(courseName,
              hint: 'edit_course.enter_course_name'.tr(),
              prefixIcon: Iconsax.book),
          const Gap(16),

          // Price
          Text('edit_course.price'.tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14)),
          const Gap(8),
          _buildTextField(price,
              hint: 'edit_course.enter_price'.tr(),
              keyboardType: TextInputType.number,
              prefixIcon: Iconsax.dollar_circle),
          const Gap(16),

          // Category
          Text('edit_course.category'.tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14)),
          const Gap(8),
          _buildTextField(catController,
              hint: 'edit_course.enter_category'.tr(),
              prefixIcon: Iconsax.category),
          const Gap(16),

          // Description
          Text('edit_course.description'.tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 14)),
          const Gap(8),
          _buildTextField(description,
              hint: 'edit_course.enter_description'.tr(),
              maxLines: 5,
              prefixIcon: Iconsax.note),
          const Gap(32),

          // Update Button
          BlocConsumer<InstructorCoursesCubit, CourseState>(
            listener: (context, state) {
              if (state is UpdateCourseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('edit_course.update_success'.tr()),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InsHomeScreen()));
              } else if (state is UpdateCourseFaild) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('edit_course.update_error'.tr()),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is UpdateCourseLoading;

              return MainButton(
                backGroundColor: primaryColor,
                text: isLoading
                    ? 'edit_course.updating'.tr()
                    : 'edit_course.update_button'.tr(),
                textColor: white,
                onTap: isLoading
                    ? null
                    : () {
                        context.read<InstructorCoursesCubit>().UpdateCourse(
                              title: courseName.text,
                              description: description.text,
                              price: double.tryParse(price.text) ?? 0,
                              category: catController.text,
                              courseImage: courseImage,
                              CourseId: widget.course.id,
                            );
                      },
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.gallery_add, size: 40, color: Colors.grey[600]),
        const Gap(8),
        Text('edit_course.upload_image'.tr(),
            style: TextStyle(color: Colors.grey[600])),
        const Gap(4),
        Text('edit_course.image_formats'.tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {String? hint,
      int maxLines = 1,
      TextInputType? keyboardType,
      IconData? prefixIcon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: maxLines > 1 ? 16 : 0),
      ),
    );
  }
}
