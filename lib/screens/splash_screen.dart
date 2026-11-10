import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QcashColors.green,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Opacity(
              opacity: scale.clamp(0, 1),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Image.asset('assets/images/qcash_logo_white.png', width: 220),
        ),
      ),
    );
  }
}
