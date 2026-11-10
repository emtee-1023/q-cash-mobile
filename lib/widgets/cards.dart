import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: QcashColors.navy,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.isLarge = false,
    this.highlight = false,
    this.highlightColor,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final bool isLarge;
  final bool highlight;
  final Color? highlightColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? QcashColors.green;
    final hl = highlightColor ?? QcashColors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? hl : QcashColors.iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: highlight
                        ? Colors.white.withValues(alpha: 0.22)
                        : accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: highlight ? Colors.white : accent,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: highlight
                        ? Colors.white.withValues(alpha: 0.9)
                        : QcashColors.textGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 24 : 17,
              fontWeight: FontWeight.w800,
              color: highlight ? Colors.white : QcashColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight = FontWeight.w600,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: QcashColors.textGray),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueWeight,
                color: valueColor ?? QcashColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: QcashColors.iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: QcashColors.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                positive ? Icons.south_west : Icons.north_east,
                size: 18,
                color: positive ? QcashColors.green : QcashColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: QcashColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: QcashColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${positive ? '+' : '-'}$amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: positive ? QcashColors.green : QcashColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalloutBox extends StatelessWidget {
  const CalloutBox({
    super.key,
    required this.text,
    this.icon,
    this.centered = true,
  });

  final String text;
  final IconData? icon;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: QcashColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QcashColors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: QcashColors.green),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                fontSize: 12.5,
                color: QcashColors.navy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
