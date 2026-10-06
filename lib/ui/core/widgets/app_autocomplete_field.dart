import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_field_style.dart';
import 'app_text_field.dart';

/// Text field with a filtered suggestion list.
///
/// Mirrors the web app's make combobox: typing filters the suggestions, but
/// only a listed option is reported through [onChanged] (an empty string
/// otherwise), and unmatched text is cleared when the field loses focus.
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
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus && _matchingOption(controller.text) == null) {
          controller.clear();
        }
      },
      child: AppTextField(
        hintText: hintText,
        controller: controller,
        focusNode: focusNode,
        onChanged: (text) => onChanged(_matchingOption(text) ?? ''),
      ),
    );
  }

  /// The listed option equal to [text] (ignoring case and surrounding
  /// spaces), or null when the text is not an option.
  String? _matchingOption(String text) {
    final normalizedText = text.trim().toLowerCase();
    if (normalizedText.isEmpty) return null;

    for (final option in suggestionsFor(text)) {
      if (option.toLowerCase() == normalizedText) return option;
    }
    return null;
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
