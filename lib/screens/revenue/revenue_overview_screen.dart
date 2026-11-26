import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RevenueOverviewScreen extends ConsumerWidget {
  const RevenueOverviewScreen({super.key});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    if (business == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      );
    }

    final analyticsAsync = ref.watch(analyticsProvider(business.id));
    final transactionsAsync = ref.watch(
      analyticsTransactionsProvider(business.id),
    );
    final assessment = ref.watch(accessControllerProvider).assessment;
    final analytics = analyticsAsync.value;
    final transactions = transactionsAsync.value ?? const <Transaction>[];
    final monthly = _monthlyRevenue(transactions);
    final daily = _dailyRevenue(transactions);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Revenue Overview', showBack: true),
            Expanded(
              child: RefreshIndicator(
                color: QcashColors.green,
                onRefresh: () async {
                  ref.invalidate(analyticsProvider(business.id));
                  ref.invalidate(analyticsTransactionsProvider(business.id));
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: analytics == null
                      ? _AnalyticsLoading(
                          hasError: analyticsAsync.hasError,
                          error: analyticsAsync.error,
                          onRetry: () =>
                              ref.invalidate(analyticsProvider(business.id)),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const CalloutBox(
                              text:
                                  'Analytics are based on your Paybill '
                                  'transactions and latest assessment.',
                              icon: Icons.auto_graph,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    label: "Today's earnings",
                                    value: formatMinor(
                                      analytics.todayEarningsMinor,
                                    ),
                                    icon: Icons.trending_up,
                                    iconColor: QcashColors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    label: "Last month's earnings",
                                    value: formatMinor(
                                      analytics.lastMonthEarningsMinor,
                                    ),
                                    icon: Icons.calendar_month_outlined,
                                    iconColor: QcashColors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    label: 'Available balance',
                                    value: formatMinor(
                                      analytics.availableBalanceMinor,
                                    ),
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconColor: QcashColors.purpleAlt,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    label: 'Outstanding',
                                    value: formatMinor(
                                      analytics.outstandingBalanceMinor,
                                    ),
                                    icon: Icons.receipt_long_outlined,
                                    iconColor: QcashColors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SectionLabel('Revenue Trend · Last 6 Months'),
                            _MonthlyRevenueChart(data: monthly),
                            const SizedBox(height: 24),
                            const SectionLabel('Daily Revenue · Last 14 Days'),
                            _DailyRevenueChart(data: daily),
                            const SizedBox(height: 24),
                            const SectionLabel('Recent Monthly Totals'),
                            InfoCard(
                              children: monthly.reversed.take(3).map((entry) {
                                return KeyValueRow(
                                  label: entry.label,
                                  value: formatMinor(entry.value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            if (assessment?.predictedRevenueMinor != null) ...[
                              StatCard(
                                label: 'Predicted Monthly Revenue',
                                value: formatMinor(
                                  assessment!.predictedRevenueMinor!,
                                ),
                                icon: Icons.auto_graph,
                                iconColor: QcashColors.green,
                              ),
                              const SizedBox(height: 12),
                            ],
                            StatCard(
                              label: 'Eligible Early Access',
                              value: formatMinor(
                                analytics.availableAdvanceMinor,
                              ),
                              isLarge: true,
                              highlight: true,
                              highlightColor: QcashColors.navy,
                              icon: Icons.bolt,
                            ),
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

  List<_ChartPoint> _monthlyRevenue(List<Transaction> transactions) {
    final now = DateTime.now();
    final result = <_ChartPoint>[];
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      var total = 0;
      for (final transaction in transactions) {
        final time = transaction.transactionTime.toLocal();
        if (transaction.isInflow &&
            time.year == month.year &&
            time.month == month.month) {
          total += transaction.amountMinor;
        }
      }
      result.add(_ChartPoint(_months[month.month - 1], total));
    }
    return result;
  }

  List<_ChartPoint> _dailyRevenue(List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <_ChartPoint>[];
    for (var i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      var total = 0;
      for (final transaction in transactions) {
        final time = transaction.transactionTime.toLocal();
        if (transaction.isInflow &&
            time.year == day.year &&
            time.month == day.month &&
            time.day == day.day) {
          total += transaction.amountMinor;
        }
      }
      result.add(_ChartPoint('${day.day} ${_months[day.month - 1]}', total));
    }
    return result;
  }
}

class _ChartPoint {
  const _ChartPoint(this.label, this.value);

  final String label;
  final int value;
}

class _AnalyticsLoading extends StatelessWidget {
  const _AnalyticsLoading({
    required this.hasError,
    required this.error,
    required this.onRetry,
  });

  final bool hasError;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CalloutBox(
            text: 'Could not load analytics. ${error ?? ''}'.trim(),
            icon: Icons.cloud_off_outlined,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: QcashColors.green),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _MonthlyRevenueChart extends StatelessWidget {
  const _MonthlyRevenueChart({required this.data});

  final List<_ChartPoint> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<int>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: context.qc.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((entry) {
                final factor = maxValue == 0
                    ? 0.0
                    : (entry.value / maxValue).clamp(0.05, 1.0);
                return Expanded(
                  child: Tooltip(
                    message: formatMinor(entry.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FractionallySizedBox(
                        heightFactor: factor,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: entry.value == maxValue && maxValue != 0
                                ? QcashColors.green
                                : QcashColors.green.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.map((entry) {
              return Expanded(
                child: Text(
                  entry.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: context.qc.muted),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DailyRevenueChart extends StatelessWidget {
  const _DailyRevenueChart({required this.data});

  final List<_ChartPoint> data;

  @override
  Widget build(BuildContext context) {
    final values = data.map((entry) => entry.value).toList();
    final mid = data.length ~/ 2;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: context.qc.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _LineChartPainter(
                  values: values,
                  lineColor: QcashColors.green,
                  gridColor: context.qc.divider,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.first.label,
                style: TextStyle(fontSize: 10, color: context.qc.muted),
              ),
              Text(
                data[mid].label,
                style: TextStyle(fontSize: 10, color: context.qc.muted),
              ),
              Text(
                data.last.label,
                style: TextStyle(fontSize: 10, color: context.qc.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  final List<int> values;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );

    final maxValue = values.reduce(math.max);
    final points = <Offset>[];
    final step = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    for (var i = 0; i < values.length; i++) {
      final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
      points.add(Offset(step * i, size.height - ratio * size.height));
    }

    if (maxValue == 0) {
      final flat = Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        flat,
      );
      return;
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    canvas.drawCircle(points.last, 3.5, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
