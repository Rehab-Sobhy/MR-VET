import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class MainButton extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final double? width;
  final double? radius;
  final Color? backGroundColor;
  final double? height;
  final void Function()? onTap;
  Color? textColor;
  final double fontSize;
  BoxBorder? border;
  FontWeight fontWeight;
  MainButton(
      {super.key,
      this.fontWeight = FontWeight.normal,
      this.text,
      this.border,
      this.radius = 20,
      this.style,
      this.width = 335,
      this.backGroundColor,
      this.height = 35,
      this.textColor,
      this.fontSize = 10,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: height!.h,
          width: width!.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius!),
              color: backGroundColor,
              border: border
              // boxShadow: const [
              //   // BoxShadow(
              //   //     blurStyle: BlurStyle.outer,
              //   //     blurRadius: 5,
              //   //     color: blackShadowButton)
              // ],
              ),
          child: Center(
            child: Text(
              text ?? "",
              style: TextStyle(color: textColor),
            ),
          )),
    );
  }
}
