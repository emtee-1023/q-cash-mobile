import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'auth_providers.dart';
import 'providers.dart';

class NotificationInbox {
  const NotificationInbox({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.loadingMore = false,
  });

  static const empty = NotificationInbox(
    items: [],
    unreadCount: 0,
    currentPage: 1,
    lastPage: 1,
    total: 0,
  );

  final List<AppNotification> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool loadingMore;

  bool get hasMore => currentPage < lastPage;

  NotificationInbox copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? loadingMore,
  }) {
    return NotificationInbox(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class NotificationInboxNotifier extends AsyncNotifier<NotificationInbox> {
  static const _perPage = 20;

  @override
  Future<NotificationInbox> build() async {
    if (!ref.watch(authControllerProvider).isAuthenticated) {
      return NotificationInbox.empty;
    }
    return _load();
  }

  Future<NotificationInbox> _load() async {
    final repository = ref.read(notificationRepositoryProvider);
    final page = await repository.list(perPage: _perPage);
    final unread = await repository.unreadCount();

    return NotificationInbox(
      items: page.items,
      unreadCount: unread,
      currentPage: page.currentPage,
      lastPage: page.lastPage,
      total: page.total,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMore() async {
    final inbox = state.value;
    if (inbox == null || !inbox.hasMore || inbox.loadingMore) return;

    state = AsyncValue.data(inbox.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(notificationRepositoryProvider)
          .list(page: inbox.currentPage + 1, perPage: _perPage);
      final existing = inbox.items.map((n) => n.id).toSet();
      final merged = [
        ...inbox.items,
        ...page.items.where((n) => !existing.contains(n.id)),
      ];
      state = AsyncValue.data(
        inbox.copyWith(
          items: merged,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          total: page.total,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(inbox.copyWith(loadingMore: false));
    }
  }

  Future<void> markAsRead(String id) async {
    final inbox = state.value;
    if (inbox == null) return;
    AppNotification? current;
    for (final notification in inbox.items) {
      if (notification.id == id) {
        current = notification;
        break;
      }
    }
    if (current == null || current.isRead) return;

    final updated = await ref
        .read(notificationRepositoryProvider)
        .markAsRead(id);
    final items = [
      for (final notification in inbox.items)
        if (notification.id == id) updated else notification,
    ];
    state = AsyncValue.data(
      inbox.copyWith(
        items: items,
        unreadCount: inbox.unreadCount > 0 ? inbox.unreadCount - 1 : 0,
      ),
    );
  }

  Future<void> markAllAsRead() async {
    final inbox = state.value;
    if (inbox == null || inbox.unreadCount == 0) return;

    await ref.read(notificationRepositoryProvider).markAllAsRead();
    final now = DateTime.now();
    final items = [
      for (final notification in inbox.items)
        if (notification.isRead)
          notification
        else
          notification.copyWith(readAt: now),
    ];
    state = AsyncValue.data(inbox.copyWith(items: items, unreadCount: 0));
  }

  /// Refreshes the newest page without flashing a loading state and merges
  /// new items into any pages already loaded. Safe to call from a background
  /// poll.
  Future<void> refreshInBackground() async {
    final inbox = state.value;
    if (inbox == null) return;
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final page = await repository.list(perPage: _perPage);
      final unread = await repository.unreadCount();
      final current = state.value;
      if (current == null) return;
      final fetchedIds = page.items.map((n) => n.id).toSet();
      final items = [
        ...page.items,
        ...current.items.where((n) => !fetchedIds.contains(n.id)),
      ];
      state = AsyncValue.data(
        current.copyWith(
          items: items,
          unreadCount: unread,
          lastPage: page.lastPage,
          total: page.total,
        ),
      );
    } catch (_) {
      // A failed background refresh should never surface an error to the user.
    }
  }

  /// Refreshes only the badge count, leaving the loaded list intact. Safe to
  /// call from a background poll.
  Future<void> refreshUnreadCount() async {
    final inbox = state.value;
    if (inbox == null) return;
    try {
      final unread = await ref
          .read(notificationRepositoryProvider)
          .unreadCount();
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(unreadCount: unread));
      }
    } catch (_) {
      // A failed background refresh should never surface an error to the user.
    }
  }
}

final notificationInboxProvider =
    AsyncNotifierProvider<NotificationInboxNotifier, NotificationInbox>(
      NotificationInboxNotifier.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationInboxProvider).value?.unreadCount ?? 0;
});
