import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/notifications_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TulipTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: Text(
                'Mark all read',
                style: TulipTextStyles.label.copyWith(color: TulipColors.sage),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        color: TulipColors.sage,
        child: notificationsAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, ref, error),
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationsList(context, ref, notifications);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TulipColors.roseDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load notifications',
              style: TulipTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(notificationsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: TulipTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    // Group by read status
    final unread = notifications.where((n) => !n.read).toList();
    final read = notifications.where((n) => n.read).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unread.isNotEmpty) ...[
          Text('New', style: TulipTextStyles.label),
          const SizedBox(height: 8),
          ...unread.map((notification) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, ref, notification),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (read.isNotEmpty) ...[
          Text('Earlier', style: TulipTextStyles.label),
          const SizedBox(height: 8),
          ...read.map((notification) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, ref, notification),
                ),
              )),
        ],
      ],
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    // Mark as read if unread
    if (!notification.read) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Navigate to target if available
    if (notification.targetPath != null) {
      context.push(notification.targetPath!);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : TulipColors.sageLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.read ? TulipColors.taupeLight : TulipColors.sage.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 20,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TulipTextStyles.body.copyWith(
                      fontWeight: notification.read ? FontWeight.w400 : FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TulipTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: TulipColors.sage,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.notificationType) {
      case 'comment_on_stay':
      case 'comment_reply':
        return Icons.chat_bubble_outline;
      case 'collaboration_invite':
        return Icons.person_add_outlined;
      case 'collaboration_accepted':
        return Icons.group_outlined;
      case 'stay_updated':
        return Icons.edit_outlined;
      case 'bucket_list_completed':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconBackgroundColor() {
    final ringColor = notification.ringColor ?? 'sage';
    switch (ringColor) {
      case 'lavender':
        return TulipColors.lavenderLight;
      case 'rose':
        return TulipColors.roseLight;
      case 'taupe':
        return TulipColors.taupeLight;
      default:
        return TulipColors.sageLight;
    }
  }

  Color _getIconColor() {
    final ringColor = notification.ringColor ?? 'sage';
    switch (ringColor) {
      case 'lavender':
        return TulipColors.lavenderDark;
      case 'rose':
        return TulipColors.roseDark;
      case 'taupe':
        return TulipColors.taupeDark;
      default:
        return TulipColors.sageDark;
    }
  }
}
