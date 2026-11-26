import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final faqs = query.isEmpty
        ? _faqs
        : _faqs
              .where(
                (faq) =>
                    faq.title.toLowerCase().contains(query) ||
                    faq.body.toLowerCase().contains(query),
              )
              .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Help & Support', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search FAQs',
                        prefixIcon: Icon(Icons.search, color: context.qc.muted),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Frequently Asked Questions'),
                    if (faqs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No FAQs match your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.qc.muted),
                        ),
                      )
                    else
                      ...faqs.map(
                        (faq) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FaqItem(faq: faq),
                        ),
                      ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Contact Support',
                      color: QcashColors.green,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq {
  const _Faq({required this.title, required this.body});

  final String title;
  final String body;
}

const _faqs = [
  _Faq(
    title: 'How long does it take to qualify for a cash advance?',
    body:
        'You need at least 14 days of eligible Paybill transaction history, '
        'plus enough transactions for us to assess your business. Once you '
        'meet this, your cash advance offer becomes available.',
  ),
  _Faq(
    title: 'How does QCash work?',
    body:
        'QCash reviews the payments your business collects through its '
        'Paybill account. It uses that history to estimate your revenue and '
        'offer a cash advance against future earnings. As you keep collecting '
        'payments, QCash keeps updating your offer.',
  ),
  _Faq(
    title: 'How does 0% interest work?',
    body:
        'QCash charges no interest. Instead, a small access fee of 2% applies — '
        'for example, a KES 1,000 advance costs KES 20. The fee is always shown '
        'before you accept an offer.',
  ),
  _Faq(
    title: 'How do repayments work?',
    body:
        'Repayment happens automatically from a share of your eligible '
        'incoming payments while an advance is outstanding. You can also '
        'repay early by choosing your QCash wallet or paying directly via '
        'M-Pesa STK push.',
  ),
  _Faq(
    title: 'How do the Paybill and account number work?',
    body:
        'QCash uses one shared Paybill for all businesses. Each business gets '
        'its own unique account number, shown on your dashboard. When '
        'collecting payments, use the QCash Paybill together with your '
        'business account number so the payment is matched to your business.',
  ),
];

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.faq});

  final _Faq faq;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.qc.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? QcashColors.green.withValues(alpha: 0.35)
                : context.qc.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.qc.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.qc.muted,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.faq.body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: context.qc.muted,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
