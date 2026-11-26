import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/app_notification.dart';
import '../../core/providers/notification_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshInBackground();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshInBackground();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _refreshInBackground() {
    ref.read(notificationInboxProvider.notifier).refreshInBackground();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels < 200) {
      ref.read(notificationInboxProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() =>
      ref.read(notificationInboxProvider.notifier).refresh();

  Future<void> _markAllAsRead() async {
    try {
      await ref.read(notificationInboxProvider.notifier).markAllAsRead();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      await ref
          .read(notificationInboxProvider.notifier)
          .markAsRead(notification.id);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.toString())));
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(notificationInboxProvider);
    final unread = inboxAsync.value?.unreadCount ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Notifications',
              showBack: true,
              trailing: unread > 0
                  ? TextButton(
                      onPressed: _markAllAsRead,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 40),
                        foregroundColor: QcashColors.green,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Mark all'),
                    )
                  : null,
            ),
            Expanded(
              child: inboxAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: QcashColors.green),
                ),
                error: (error, _) =>
                    _ErrorState(message: error.toString(), onRetry: _refresh),
                data: (inbox) {
                  if (inbox.items.isEmpty) {
                    return _EmptyState(onRefresh: _refresh);
                  }
                  final showLoader = inbox.hasMore || inbox.loadingMore;
                  return RefreshIndicator(
                    color: QcashColors.green,
                    onRefresh: _refresh,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: inbox.items.length + (showLoader ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= inbox.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: QcashColors.green,
                                ),
                              ),
                            ),
                          );
                        }
                        final notification = inbox.items[index];
                        return _NotificationTile(
                          notification: notification,
                          onTap: () => _markAsRead(notification),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = _visualsFor(context, notification.event);
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? QcashColors.green.withValues(alpha: 0.06)
              : context.qc.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread
                ? QcashColors.green.withValues(alpha: 0.25)
                : context.qc.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: visuals.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(visuals.icon, size: 22, color: visuals.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: context.qc.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRelativeTime(notification.createdAt),
                        style: TextStyle(fontSize: 11, color: context.qc.muted),
                      ),
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: context.qc.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: QcashColors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _NotificationVisuals _visualsFor(BuildContext context, String event) {
    switch (event) {
      case 'payment_received':
        return const _NotificationVisuals(
          icon: Icons.call_received,
          color: QcashColors.green,
        );
      case 'withdrawal_completed':
        return const _NotificationVisuals(
          icon: Icons.arrow_upward,
          color: QcashColors.orange,
        );
      case 'advance_disbursed':
        return const _NotificationVisuals(
          icon: Icons.bolt,
          color: QcashColors.purpleAlt,
        );
      default:
        return _NotificationVisuals(
          icon: Icons.notifications_none,
          color: context.qc.text,
        );
    }
  }
}

class _NotificationVisuals {
  const _NotificationVisuals({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: QcashColors.green,
      onRefresh: onRefresh,
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120),
          Icon(Icons.notifications_none, size: 48, color: context.qc.muted),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.qc.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Payments, withdrawals and advances will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.qc.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: context.qc.muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.qc.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: QcashColors.green),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
