import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Provider for the list of notifications
final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return _fetchNotifications();
  }

  Future<List<AppNotification>> _fetchNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    return repository.getNotifications();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  /// Mark a notification as read
  Future<void> markAsRead(int id) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAsRead(id);

    // Update local state
    final notifications = state.valueOrNull ?? [];
    state = AsyncValue.data(
      notifications.map((n) => n.id == id ? n.copyWith(read: true) : n).toList(),
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAllAsRead();

    // Update local state
    final notifications = state.valueOrNull ?? [];
    state = AsyncValue.data(
      notifications.map((n) => n.copyWith(read: true)).toList(),
    );
  }
}

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.whenOrNull(
    data: (notifications) => notifications.where((n) => !n.read).length,
  ) ?? 0;
});
