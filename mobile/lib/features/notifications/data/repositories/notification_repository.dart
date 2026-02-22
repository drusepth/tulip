import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Fetch all notifications for the current user
  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiClient.get<List<dynamic>>(Endpoints.notifications);
    final data = response.data ?? [];
    return data.map((json) => AppNotification.fromJson(_convertKeys(json))).toList();
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int id) async {
    await _apiClient.patch(Endpoints.notificationRead(id));
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _apiClient.post(Endpoints.notificationsMarkAllRead);
  }

  /// Convert snake_case keys to camelCase
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toCamelCase(key);
      final newValue = value is Map<String, dynamic>
          ? _convertKeys(value)
          : value is List
              ? value.map((e) => e is Map<String, dynamic> ? _convertKeys(e) : e).toList()
              : value;
      return MapEntry(newKey, newValue);
    });
  }

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }
}
