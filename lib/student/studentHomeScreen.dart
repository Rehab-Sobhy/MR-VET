import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MR VET"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(40),
            Row(
              children: [
                Text("instructors"),
                Spacer(),
                Text("showall".tr()),
              ],
            ),
            SizedBox(
              height: 130,
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 130,
                        height: 90,
                        child: Card(
                          child: Image.asset("assets/images/check2.jpg"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Text("courses"),
                Spacer(),
                Text("showall".tr()),
              ],
            ),
            Expanded(
              child: GridView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 130,
                      height: 90,
                      child: Card(
                        child: Image.asset("assets/images/check2.jpg"),
                      ),
                    ),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
