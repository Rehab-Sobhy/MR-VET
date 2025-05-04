import 'package:education_app/resources/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String hintText = "";
  double fontsize;
  bool isShown;
  TextEditingController cotroller;
  final Widget? suffix;
  final void Function(String)? onchange;
  CustomTextField({
    super.key,
    required this.cotroller,
    this.isShown = false,
    this.suffix,
    this.fontsize = 12,
    this.hintText = "",
    this.onchange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: cotroller,
        onChanged: onchange,
        obscureText: isShown,
        decoration: InputDecoration(
            fillColor: grey,
            suffix: suffix,
            hintText: hintText,
            hintStyle:
                TextStyle(fontSize: fontsize, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: grey))),
      ),
    );
  }
}
