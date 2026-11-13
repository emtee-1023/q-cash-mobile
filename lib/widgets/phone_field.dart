import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../theme/app_theme.dart';

/// Formats raw digits as the Kenyan local format `07XX XXX XXX` as the user
/// types, so phone numbers are entered simply like `07...`.
class KenyanPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// A phone number field that accepts `07XX XXX XXX` and normalises to the
/// canonical `+254…` form via [normalizeKenyanPhone].
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.label = 'Phone Number',
    this.hint = '0712 345 678',
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [KenyanPhoneInputFormatter()],
      validator: validator ??
          (v) {
            final normalized = normalizeKenyanPhone(v ?? '');
            if (normalized == null) return 'Enter a valid phone number';
            return null;
          },
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelStyle: const TextStyle(color: QcashColors.navy),
        filled: true,
        fillColor: QcashColors.iconBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QcashColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QcashColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QcashColors.green, width: 1.5),
        ),
      ),
    );
  }
}
