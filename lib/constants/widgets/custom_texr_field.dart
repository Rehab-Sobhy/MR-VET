import 'package:education_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldCard extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool isPassword;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool autoFocus;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final double borderRadius;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCounter;
  final int? maxLength;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final bool enabled;

  const CustomTextFieldCard({
    Key? key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.isPassword = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.autoFocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.labelText,
    this.helperText,
    this.errorText,
    this.borderRadius = 12.0,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = Colors.black,
    this.fillColor,
    this.contentPadding,
    this.showCounter = false,
    this.maxLength,
    this.hintStyle,
    this.textStyle,
    this.enabled = true,
  }) : super(key: key);

  @override
  _CustomTextFieldCardState createState() => _CustomTextFieldCardState();
}

class _CustomTextFieldCardState extends State<CustomTextFieldCard> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultFillColor = isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                color: _focusNode.hasFocus
                    ? widget.focusedBorderColor
                    : widget.borderColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          style: widget.textStyle ??
              TextStyle(
                color: widget.enabled ? primaryColor : Colors.grey[600],
                fontSize: 16,
              ),
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          autofocus: widget.autoFocus,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
            filled: true,
            fillColor: widget.fillColor ?? defaultFillColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.focusedBorderColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _focusNode.hasFocus
                          ? widget.focusedBorderColor
                          : widget.borderColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: widget.prefixIcon,
                  )
                : null,
            helperText: widget.helperText,
            errorText: widget.errorText,
            counter: widget.showCounter ? null : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
