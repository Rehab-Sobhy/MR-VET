import 'package:education_app/instructor/coursesCubit.dart';
import 'package:education_app/resources/colors.dart';
import 'package:education_app/resources/customTextField.dart';
import 'package:education_app/resources/widgets/mainButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  TextEditingController courseName = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController instructor = TextEditingController();
  TextEditingController price = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("AddCourse"),
              Gap(20),
              Row(
                children: [
                  Text("courseName"),
                ],
              ),
              CustomTextField(cotroller: courseName),
              Row(
                children: [
                  Text("price"),
                ],
              ),
              CustomTextField(cotroller: courseName),
              Row(
                children: [
                  Text("description"),
                ],
              ),
              CustomTextField(cotroller: courseName),
              Row(
                children: [
                  Text("instructor"),
                ],
              ),
              CustomTextField(cotroller: courseName),
              Gap(30),
              MainButton(
                  backGroundColor: primaryColor,
                  text: "addCOurse",
                  textColor: white,
                  onTap: () {
                    context.read<CoursesCubit>().addCourse(
                          title: 'Flutter Basics',
                          description: 'Learn Flutter from scratch',
                          price: '100',
                          instructor: 'John Doe',
                        );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
