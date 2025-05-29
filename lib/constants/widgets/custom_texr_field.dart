import 'package:education_app/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFieldCard extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool isPassword;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly; // NEW
  final VoidCallback? onTap; // NEW

  CustomTextFieldCard({
    Key? key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
    this.readOnly = false, // default false
    this.onTap,
  }) : super(key: key);

  @override
  _CustomTextFieldCardState createState() => _CustomTextFieldCardState();
}

class _CustomTextFieldCardState extends State<CustomTextFieldCard> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      style: TextStyle(color: primaryColor),
      validator: widget.validator,
      readOnly: widget.readOnly, // make field non-editable
      onTap: widget.onTap, // trigger callback when tapped
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: primaryColor),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(25),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}
