import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _courseImage;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _courseImage = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('image_pick_error'.tr())),
      );
    }
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('create_new_course'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _courseImage != null
                        ? Colors.transparent
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: _courseImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_courseImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.gallery_add,
                              size: 40, color: Colors.grey[600]),
                          const Gap(8),
                          Text('tap_to_upload'.tr(),
                              style: TextStyle(color: Colors.grey[600])),
                          const Gap(4),
                          Text('image_formats'.tr(),
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const Gap(24),

            // Course Name Field
            Text('course_name'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(_courseNameController,
                hint: 'enter_course_name'.tr(), prefixIcon: Iconsax.book),
            const Gap(16),

            // Price Field
            Text('price'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(_priceController,
                hint: 'enter_price'.tr(),
                keyboardType: TextInputType.number,
                prefixIcon: Iconsax.dollar_circle),
            const Gap(16),

            // Category Field
            Text('category'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(_categoryController,
                hint: 'enter_category'.tr(), prefixIcon: Iconsax.category),
            const Gap(16),

            // Description Field
            Text('description'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(_descriptionController,
                hint: 'enter_description'.tr(),
                maxLines: 5,
                prefixIcon: Iconsax.note),
            const Gap(32),

            // Submit Button
            BlocConsumer<InstructorCoursesCubit, CourseState>(
              listener: (context, state) {
                if (state is AddCourseSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('course_added_success'.tr()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else if (state is AddCourseFaild) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('error_occurred'.tr()),
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
                return MainButton(
                  backGroundColor: primaryColor,
                  text: "add_course".tr(),
                  textColor: Colors.white,
                  onTap: () {
                    if (_courseNameController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        _priceController.text.isEmpty ||
                        _categoryController.text.isEmpty ||
                        _courseImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('fill_all_fields'.tr()),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    context.read<InstructorCoursesCubit>().addCourse(
                          title: _courseNameController.text,
                          description: _descriptionController.text,
                          price: double.tryParse(_priceController.text) ?? 0,
                          category: _categoryController.text,
                          courseImage: _courseImage,
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: context.locale.languageCode == 'ar'
          ? TextAlign.right
          : TextAlign.left,
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
