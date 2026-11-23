import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/format.dart';
import 'package:mobile/core/models/app_notification.dart';

void main() {
  group('AppNotification.fromJson', () {
    test('parses an unread notification with its payload', () {
      final notification = AppNotification.fromJson({
        'id': '9b2f3c1e-0000-4000-8000-000000000001',
        'type': 'payment_received',
        'data': {
          'type': 'payment_received',
          'title': 'Payment received',
          'body': 'A payment of KES 150.75 was received from John Doe Kamau.',
          'business_id': 7,
        },
        'read_at': null,
        'created_at': '2026-11-22T10:00:00.000000Z',
        'updated_at': '2026-11-22T10:00:00.000000Z',
      });

      expect(notification.id, '9b2f3c1e-0000-4000-8000-000000000001');
      expect(notification.title, 'Payment received');
      expect(
        notification.body,
        'A payment of KES 150.75 was received from John Doe Kamau.',
      );
      expect(notification.event, 'payment_received');
      expect(notification.businessId, 7);
      expect(notification.isRead, isFalse);
      expect(notification.createdAt, isNotNull);
    });

    test('marks a notification as read and falls back to the class type', () {
      final notification = AppNotification.fromJson({
        'id': 'abc',
        'type': 'advance_disbursed',
        'data': <String, dynamic>{},
        'read_at': '2026-11-22T10:05:00.000000Z',
      });

      expect(notification.isRead, isTrue);
      expect(notification.event, 'advance_disbursed');
      expect(notification.title, 'Notification');
      expect(notification.body, isEmpty);
    });
  });

  group('formatRelativeTime', () {
    test('formats recent timestamps', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now), 'Just now');
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 5))),
        '5m ago',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 2))),
        '2h ago',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 3))),
        '3d ago',
      );
      expect(formatRelativeTime(null), isEmpty);
    });
  });
}
