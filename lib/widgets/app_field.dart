import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: QcashColors.navy,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix,
              prefixIcon: prefixText == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 14, right: 4),
                      child: Text(
                        prefixText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: QcashColors.textGray,
                        ),
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
  });

  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: QcashColors.navy,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            hint: Text(hint),
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: QcashColors.textGray),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A generic dropdown for value objects (business types, counties, wards…)
/// that exposes a typed selection while displaying a human label.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.labelOf,
    this.value,
    this.onChanged,
    this.loading = false,
  });

  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: QcashColors.navy,
              ),
            ),
          ),
          DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            hint: Text(hint),
            decoration: InputDecoration(
              suffixIcon: loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: QcashColors.green,
                        ),
                      ),
                    )
                  : const Icon(Icons.keyboard_arrow_down,
                      color: QcashColors.textGray),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(labelOf(e))))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
