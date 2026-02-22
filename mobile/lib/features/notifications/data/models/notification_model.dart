import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required int id,
    required String notificationType,
    required String message,
    String? iconName,
    String? ringColor,
    String? targetPath,
    @Default(false) bool read,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  /// Returns the appropriate icon for the notification type
  String get iconCode {
    switch (notificationType) {
      case 'comment_on_stay':
      case 'comment_reply':
        return 'chat_bubble';
      case 'collaboration_invite':
        return 'person_add';
      case 'collaboration_accepted':
        return 'group';
      case 'stay_updated':
        return 'edit';
      case 'bucket_list_completed':
        return 'check_circle';
      default:
        return 'notifications';
    }
  }

  /// Returns formatted relative time
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${(diff.inDays / 7).floor()}w ago';
    }
  }
}
