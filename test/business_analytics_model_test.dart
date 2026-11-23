import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/models/business_analytics.dart';

void main() {
  group('BusinessAnalytics.fromJson', () {
    test('parses string amounts and the latest advance', () {
      final analytics = BusinessAnalytics.fromJson({
        'today_earnings_minor': '150075',
        'last_month_earnings_minor': '4200000',
        'outstanding_balance_minor': '87500',
        'latest_advance': {
          'id': 12,
          'principal_amount_minor': '250000',
          'status': 'disbursed',
          'created_at': '2026-11-20T10:00:00.000000Z',
        },
        'available_balance_minor': '1999500',
        'available_advance_minor': '5000000',
      });

      expect(analytics.todayEarningsMinor, 150075);
      expect(analytics.lastMonthEarningsMinor, 4200000);
      expect(analytics.outstandingBalanceMinor, 87500);
      expect(analytics.latestAdvance?.principalAmountMinor, 250000);
      expect(analytics.latestAdvance?.status, 'disbursed');
      expect(analytics.availableBalanceMinor, 1999500);
      expect(analytics.availableAdvanceMinor, 5000000);
    });

    test('handles integer amounts and no latest advance', () {
      final analytics = BusinessAnalytics.fromJson({
        'today_earnings_minor': 0,
        'last_month_earnings_minor': 0,
        'outstanding_balance_minor': 0,
        'latest_advance': null,
        'available_balance_minor': 0,
        'available_advance_minor': 0,
      });

      expect(analytics.todayEarningsMinor, 0);
      expect(analytics.latestAdvance, isNull);
      expect(analytics.availableBalanceMinor, 0);
    });
  });
}
