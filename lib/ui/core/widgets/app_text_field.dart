import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_field_style.dart';

/// Text input used by the search and review forms.
///
/// Single-line by default; pass [minLines] and [maxLines] for a multiline
/// field such as the review comment box.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
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
