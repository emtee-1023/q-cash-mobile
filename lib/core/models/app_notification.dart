import '../format.dart';

/// An in-app notification delivered by the Q-Cash API.
///
/// The [type] mirrors the Laravel notification class, while [data] carries the
/// human-readable `title` / `body` plus any entity references (business,
/// transaction, withdrawal, advance) the backend included.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isRead => readAt != null;

  String get title => data['title']?.toString() ?? 'Notification';

  String get body => data['body']?.toString() ?? '';

  /// The domain event (`payment_received`, `withdrawal_completed`,
  /// `advance_disbursed`, ...). Prefers the value embedded in the payload and
  /// falls back to the notification class name.
  String get event => data['type']?.toString() ?? type;

  int? get businessId =>
      data['business_id'] == null ? null : toMinor(data['business_id']);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic> data;
    if (rawData is Map) {
      data = rawData.map((key, value) => MapEntry(key.toString(), value));
    } else {
      data = const {};
    }

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      data: data,
      readAt: parseDateTime(json['read_at']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
    id: id,
    type: type,
    data: data,
    readAt: readAt ?? this.readAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
