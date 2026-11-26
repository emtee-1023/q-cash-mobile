import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.showBell = false,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final bool showBell;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          if (showBack)
            _HeaderIconButton(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.chevron_left, size: 24),
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.qc.text,
              ),
            ),
          ),
          if (showBell)
            _HeaderIconButton(
              onTap: null,
              child: Icon(
                Icons.notifications_none,
                size: 20,
                color: context.qc.text,
              ),
            )
          else if (trailing != null)
            trailing!
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: context.qc.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
