import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_field_style.dart';
import 'app_text_field.dart';

/// Text field with a filtered suggestion list.
///
/// Mirrors the web app's make combobox: suggestions help, but the typed text is
/// kept even when it matches no option, so unlisted values stay searchable.
class AppAutocompleteField extends StatelessWidget {
  const AppAutocompleteField({
    required this.hintText,
    required this.suggestionsFor,
    required this.value,
    required this.onChanged,
    super.key,
  });

  static const _maxMenuHeight = 240.0;

  final String hintText;
  final List<String> Function(String query) suggestionsFor;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Autocomplete<String>(
        initialValue: value == null ? null : TextEditingValue(text: value!),
        optionsBuilder: (value) => suggestionsFor(value.text),
        onSelected: onChanged,
        fieldViewBuilder: _fieldView,
        optionsViewBuilder: (context, onSelected, options) =>
            _optionsView(onSelected, options.toList(), constraints.maxWidth),
      ),
    );
  }

  Widget _fieldView(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return AppTextField(
      hintText: hintText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }

  Widget _optionsView(
    ValueChanged<String> onSelected,
    List<String> options,
    double width,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: AppColors.surface,
        elevation: 4,
        borderRadius: BorderRadius.circular(AppFieldStyle.borderRadius),
        child: SizedBox(
          width: width,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxMenuHeight),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (context, index) =>
                  _option(options[index], onSelected),
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(String option, ValueChanged<String> onSelected) {
    return InkWell(
      onTap: () => onSelected(option),
      child: Padding(
        padding: AppFieldStyle.contentPadding,
        child: Text(
          option,
          style: AppFieldStyle.textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
