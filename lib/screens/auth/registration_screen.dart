import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/screen_header.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Create Account', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppTextField(label: 'Full Name', hint: 'Jane Wanjiru'),
                      const AppTextField(
                        label: 'Phone Number',
                        hint: '7XX XXX XXX',
                        prefixText: '+254 ',
                        keyboardType: TextInputType.phone,
                      ),
                      const AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const AppTextField(label: 'ID Number', hint: 'National ID'),
                      const AppTextField(
                        label: 'Password',
                        obscureText: true,
                        suffix: Icon(Icons.visibility_off, size: 20, color: QcashColors.textGray),
                      ),
                      const AppTextField(
                        label: 'Confirm Password',
                        obscureText: true,
                        suffix: Icon(Icons.visibility_off, size: 20, color: QcashColors.textGray),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Create Account',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OtpScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text(
                          'Already have an account? Log In',
                          style: TextStyle(
                            color: QcashColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}
