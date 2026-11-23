import '../format.dart';
import 'advance.dart';

class BusinessAnalytics {
  const BusinessAnalytics({
    required this.todayEarningsMinor,
    required this.lastMonthEarningsMinor,
    required this.outstandingBalanceMinor,
    this.latestAdvance,
    required this.availableBalanceMinor,
    required this.availableAdvanceMinor,
  });

  final int todayEarningsMinor;
  final int lastMonthEarningsMinor;
  final int outstandingBalanceMinor;
  final Advance? latestAdvance;
  final int availableBalanceMinor;
  final int availableAdvanceMinor;

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) =>
      BusinessAnalytics(
        todayEarningsMinor: toMinor(json['today_earnings_minor']),
        lastMonthEarningsMinor: toMinor(json['last_month_earnings_minor']),
        outstandingBalanceMinor: toMinor(json['outstanding_balance_minor']),
        latestAdvance: json['latest_advance'] is Map
            ? Advance.fromJson(json['latest_advance'] as Map<String, dynamic>)
            : null,
        availableBalanceMinor: toMinor(json['available_balance_minor']),
        availableAdvanceMinor: toMinor(json['available_advance_minor']),
      );
}
