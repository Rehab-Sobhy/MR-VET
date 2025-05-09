import 'dart:io';

import 'package:education_app/instructor/coursesCubit.dart';
import 'package:education_app/resources/colors.dart';
import 'package:education_app/resources/customTextField.dart';
import 'package:education_app/resources/widgets/mainButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController courseName = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController catController = TextEditingController();
  final TextEditingController price = TextEditingController();
  File? courseImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        courseImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دورة جديدة'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: courseImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(courseImage!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('اضغط لإضافة صورة الدورة'),
                          ],
                        ),
                      ),
              ),
            ),
            const Gap(20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('اسم الدورة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomTextField(cotroller: courseName),
            const Gap(10),
            const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('السعر', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomTextField(
                cotroller: price, keyboardType: TextInputType.number),
            const Gap(10),
            const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('القسم', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomTextField(
              cotroller: catController,
            ),
            const Gap(10),
            const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            CustomTextField(
              cotroller: description,
              maxLines: 5,
            ),
            const Gap(30),
            MainButton(
              backGroundColor: primaryColor,
              text: "إضافة الدورة",
              textColor: white,
              onTap: () {
                if (courseName.text.isEmpty ||
                    description.text.isEmpty ||
                    price.text.isEmpty ||
                    catController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("يرجى ملء جميع الحقول واختيار صورة")),
                  );
                  return;
                }

                context.read<CoursesCubit>().addCourse(
                      title: courseName.text,
                      description: description.text,
                      price: double.tryParse(price.text) ?? 0,
                      category: catController.text,
                      courseImage: courseImage,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
