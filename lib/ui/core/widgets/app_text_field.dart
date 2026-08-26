import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_field_style.dart';

/// Single-line text input used by the search forms.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: AppFieldStyle.textStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFieldStyle.hintStyle,
        filled: true,
        fillColor: AppFieldStyle.fill,
        isDense: true,
        contentPadding: AppFieldStyle.contentPadding,
        enabledBorder: AppFieldStyle.inputBorder,
        focusedBorder: AppFieldStyle.inputBorder,
        border: AppFieldStyle.inputBorder,
      ),
    );
  }
}
