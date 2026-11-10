import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _labels = [
    'Home',
    'Transactions',
    'Access',
    'Repayment',
    'Profile',
  ];

  static const _icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.south,
    Icons.swap_horiz,
    Icons.person_outline,
  ];

  static const _activeIcons = [
    Icons.home,
    Icons.receipt_long,
    Icons.south,
    Icons.swap_horiz,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A9CA3AF),
            offset: Offset(0, -12),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isCenter = index == 2;
          return Expanded(
            child: isCenter ? _centerFab(context) : _item(context, index),
          );
        }),
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final active = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active ? _activeIcons[index] : _icons[index],
            size: 24,
            color: active ? QcashColors.navy : QcashColors.textGray,
          ),
          const SizedBox(height: 4),
          Text(
            _labels[index],
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? QcashColors.navy : QcashColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerFab(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -6),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: QcashColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: QcashColors.green.withValues(alpha: 0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.south, color: Colors.white, size: 26),
          ),
        ),
        const Text(
          'Access',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: QcashColors.textGray,
          ),
        ),
      ],
    );
  }
}
