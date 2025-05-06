import 'package:education_app/auth/register/register.dart';
import 'package:education_app/auth/register/register_model.dart';
import 'package:education_app/resources/colors.dart';
import 'package:education_app/resources/widgets/mainButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChooseRole extends StatefulWidget {
  const ChooseRole({super.key});

  @override
  State<ChooseRole> createState() => _ChooseRoleState();
}

class _ChooseRoleState extends State<ChooseRole> {
  String? role;
  @override
  Widget build(BuildContext context) {
    RegisterModel registerModel = RegisterModel();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainButton(
              backGroundColor: primaryColor,
              textColor: Colors.white,
              text: "Admin",
              onTap: () {
                role = "admin";
                registerModel.role = "admin";
              },
            ),
            Gap(20),
            MainButton(
              backGroundColor: primaryColor,
              textColor: Colors.white,
              text: "Student",
              onTap: () {
                role = "student";
                registerModel.role = "student";
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterScreen(
                              role: role!,
                            )));
              },
            ),
            Gap(20),
            MainButton(
              backGroundColor: primaryColor,
              textColor: Colors.white,
              text: "Instructor",
              onTap: () {
                role = "instructor";
                registerModel.role = "instructor";
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterScreen(role: role!)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
