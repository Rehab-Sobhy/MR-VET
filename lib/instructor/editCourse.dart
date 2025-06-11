import 'dart:io';
import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

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
        initialImageUrl =
            null; // Clear the initial image URL when new image is selected
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
            const Text('تعديل الدورة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text('اسم الدورة',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(courseName,
                hint: 'أدخل اسم الدورة هنا', prefixIcon: Iconsax.book),
            const Gap(16),

            // Price
            Text('السعر',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(price,
                hint: 'أدخل سعر الدورة',
                keyboardType: TextInputType.number,
                prefixIcon: Iconsax.dollar_circle),
            const Gap(16),

            // Category
            Text('القسم',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(catController,
                hint: 'أدخل القسم', prefixIcon: Iconsax.category),
            const Gap(16),

            // Description
            Text('الوصف',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14)),
            const Gap(8),
            _buildTextField(description,
                hint: 'أدخل وصف الدورة هنا',
                maxLines: 5,
                prefixIcon: Iconsax.note),
            const Gap(32),

            // Update Button
            BlocConsumer<InstructorCoursesCubit, CourseState>(
              listener: (context, state) {
                if (state is UpdateCourseSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم تحديث الدورة بنجاح!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true); // Return success
                } else if (state is UpdateCourseFaild) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("حدث خطأ أثناء التحديث"),
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
                  text: state is UpdateCourseLoading
                      ? "جاري التحديث..."
                      : "تحديث الدورة",
                  textColor: white,
                  onTap: () {
                    if (state is UpdateCourseLoading) return;

                    if (courseName.text.isEmpty ||
                        description.text.isEmpty ||
                        price.text.isEmpty ||
                        catController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("يرجى ملء جميع الحقول المطلوبة"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.gallery_add, size: 40, color: Colors.grey[600]),
        const Gap(8),
        Text('اضغط لرفع صورة الدورة',
            style: TextStyle(color: Colors.grey[600])),
        const Gap(4),
        Text('(JPEG, PNG)',
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
