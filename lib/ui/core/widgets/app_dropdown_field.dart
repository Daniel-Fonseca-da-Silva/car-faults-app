import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_field_style.dart';

/// One selectable entry of an [AppDropdownField], pairing the value kept by the
/// caller with the text shown to the user.
class AppDropdownOption<T> {
  const AppDropdownOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Dropdown field with the same box as `AppTextField` plus a chevron.
///
/// Shows [hintText] while [value] is null.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.hintText,
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  static const _chevronSize = 20.0;

  final String hintText;
  final List<AppDropdownOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppFieldStyle.minHeight),
      padding: AppFieldStyle.boxPadding,
      decoration: AppFieldStyle.boxDecoration,
      child: DropdownButton<T>(
        value: value,
        hint: Text(hintText, style: AppFieldStyle.hintStyle),
        items: _menuItems(),
        onChanged: onChanged,
        isExpanded: true,
        style: AppFieldStyle.textStyle,
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(AppFieldStyle.borderRadius),
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.muted,
          size: _chevronSize,
        ),
      ),
    );
  }

  List<DropdownMenuItem<T>> _menuItems() {
    return [
      for (final option in options)
        DropdownMenuItem<T>(
          value: option.value,
          child: Text(option.label, overflow: TextOverflow.ellipsis),
        ),
    ];
  }
}
