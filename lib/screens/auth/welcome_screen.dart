import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Center(
                child: Image.asset(
                  'assets/images/qcash_logo_light.png',
                  width: 240,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: QcashColors.iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Zero-interest early access to your business revenue, '
                  'powered by your M-Pesa transaction data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: QcashColors.navy,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              PrimaryButton(
                label: 'Get Started',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                ),
              ),
              const SizedBox(height: 14),
              OutlineButton(
                label: 'Log In',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
