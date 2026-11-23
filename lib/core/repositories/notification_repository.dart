import '../api/api_client.dart';
import '../models/app_notification.dart';
import '../format.dart';

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final int total;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['data'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (e) => AppNotification.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <AppNotification>[];

    final meta = json['meta'];
    final metaMap = meta is Map ? meta : const {};
    final currentPage = toMinor(metaMap['current_page']);
    final lastPage = toMinor(metaMap['last_page']);

    return NotificationPage(
      items: items,
      currentPage: currentPage == 0 ? 1 : currentPage,
      lastPage: lastPage == 0 ? 1 : lastPage,
      total: toMinor(metaMap['total'] ?? items.length),
    );
  }
}

class NotificationRepository {
  NotificationRepository(this._client);

  final ApiClient _client;

  Future<NotificationPage> list({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    final res = await _client.get(
      '/notifications',
      query: {'page': page, 'per_page': perPage, if (unreadOnly) 'unread': 1},
    );
    final data = res.data;
    if (data is Map) {
      return NotificationPage.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return const NotificationPage(
      items: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
    );
  }

  Future<int> unreadCount() async {
    final res = await _client.get('/notifications/unread-count');
    final data = res.data;
    if (data is Map) return toMinor(data['unread_count']);
    return 0;
  }

  Future<AppNotification> markAsRead(String id) async {
    final res = await _client.post('/notifications/$id/read');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return AppNotification.fromJson(
        (data['data'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }
    throw ApiException('Unexpected notification payload');
  }

  Future<int> markAllAsRead() async {
    final res = await _client.post('/notifications/read-all');
    final data = res.data;
    if (data is Map) return toMinor(data['marked_read']);
    return 0;
  }
}
