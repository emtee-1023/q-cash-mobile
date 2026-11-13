import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/phone_field.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _idNumber = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _dobController = TextEditingController();
  String? _idType;
  DateTime? _dob;
  bool _obscure = true;
  bool _busy = false;

  bool get _isPassport => _idType == 'passport';

  String get _idNumberLabel => _isPassport ? 'Passport Number' : 'ID Number';

  String get _idNumberHint => _isPassport ? 'e.g. A1234567' : 'e.g. 34567890';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _idNumber.dispose();
    _password.dispose();
    _confirm.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 18, now.month, now.day);
    var initial = _dob ?? lastDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    if (initial.isBefore(firstDate)) initial = firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = formatDmy(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = normalizeKenyanPhone(_phone.text);
    if (phone == null) {
      _showError('Enter a valid phone number.');
      return;
    }
    if (_idType == null) {
      _showError('Select your ID type.');
      return;
    }
    if (_dob == null) {
      _showError('Select your date of birth.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: _name.text.trim(),
            phoneNumber: phone,
            password: _password.text,
            passwordConfirmation: _confirm.text,
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            idType: _idType!,
            identificationNumber: _idNumber.text.trim(),
            dateOfBirth: _formatDob(_dob!),
          );
      if (!mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const OtpScreen()));
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatDob(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.year.toString().padLeft(4, '0')}';

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Jane Wanjiru',
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      AppTextField(
                        label: 'Phone Number',
                        hint: '0712 345 678',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [KenyanPhoneInputFormatter()],
                        validator: (v) => normalizeKenyanPhone(v ?? '') == null
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      AppTextField(
                        label: 'Email (optional)',
                        hint: 'you@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      AppSelectField<String>(
                        label: 'ID Type',
                        hint: 'Select ID type',
                        items: const ['kenyan_national_id', 'passport'],
                        labelOf: (v) => v == 'kenyan_national_id'
                            ? 'National ID'
                            : 'Passport',
                        value: _idType,
                        onChanged: (v) => setState(() => _idType = v),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: AppTextField(
                          key: ValueKey(_idNumberLabel),
                          label: _idNumberLabel,
                          hint: _idNumberHint,
                          controller: _idNumber,
                          keyboardType: _isPassport
                              ? TextInputType.text
                              : TextInputType.number,
                          textCapitalization: _isPassport
                              ? TextCapitalization.characters
                              : TextCapitalization.none,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? '$_idNumberLabel is required'
                              : null,
                        ),
                      ),
                      _dateOfBirthField(),
                      AppTextField(
                        label: 'Password',
                        hint: 'At least 8 characters',
                        controller: _password,
                        obscureText: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: QcashColors.textGray,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Password must be at least 8 characters'
                            : null,
                      ),
                      AppTextField(
                        label: 'Confirm Password',
                        hint: 'Repeat your password',
                        controller: _confirm,
                        obscureText: _obscure,
                        validator: (v) => v != _password.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Create Account',
                        onPressed: _busy ? null : _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: QcashColors.textGray),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: QcashColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: QcashColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text: 'Create ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.navy,
                  ),
                ),
                TextSpan(
                  text: 'Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join Q-Cash and receive quick cash advances for your business.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: QcashColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Date of Birth',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: QcashColors.navy,
              ),
            ),
          ),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            showCursor: false,
            onTap: _pickDob,
            decoration: InputDecoration(
              hintText: 'Select date',
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: QcashColors.textGray,
              ),
            ),
            validator: (_) =>
                _dob == null ? 'Date of birth is required' : null,
          ),
        ],
      ),
    );
  }
}
