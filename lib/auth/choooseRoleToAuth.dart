import 'package:education_app/auth/register/registerScreen.dart';
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
                registerModel.role = "admin";
              },
            ),
            Gap(20),
            MainButton(
              backGroundColor: primaryColor,
              textColor: Colors.white,
              text: "Student",
              onTap: () {
                registerModel.role = "student";
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
            ),
            Gap(20),
            MainButton(
              backGroundColor: primaryColor,
              textColor: Colors.white,
              text: "Instructor",
              onTap: () {
                registerModel.role = "instructor";
              },
            ),
          ],
        ),
      ),
    );
  }
}
