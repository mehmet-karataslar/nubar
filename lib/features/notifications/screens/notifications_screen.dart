import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/date_utils.dart';
import 'package:nubar/features/notifications/providers/notifications_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'repost':
        return Icons.repeat;
      case 'mention':
        return Icons.alternate_email;
      case 'message':
        return Icons.mail;
      default:
        return Icons.notifications;
    }
  }

  (Color background, Color foreground) _getNotificationStyle(
    String type,
    BuildContext context,
  ) {
    final cs = Theme.of(context).colorScheme;
    switch (type) {
      case 'like':
        return (cs.error, cs.onError);
      case 'comment':
        return (cs.primary, cs.onPrimary);
      case 'follow':
        return (cs.secondary, cs.onSecondary);
      case 'repost':
        return (cs.tertiary, cs.onTertiary);
      case 'mention':
        return (cs.primaryContainer, cs.onPrimaryContainer);
      default:
        return (cs.primary, cs.onPrimary);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(realtimeNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ref.read(realtimeNotificationsProvider.notifier).markAllAsRead();
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(child: Text(l10n.error)),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                l10n.noNotifications,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(realtimeNotificationsProvider.notifier).refresh();
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final notificationStyle = _getNotificationStyle(
                  notification.type,
                  context,
                );
                return ListTile(
                  tileColor: notification.isRead
                      ? null
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                  leading: Stack(
                    children: [
                      NubarAvatar(
                        imageUrl: notification.actorAvatarUrl,
                        radius: 22,
                        fallbackText: notification.actorFullName,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: notificationStyle.$1,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            size: 12,
                            color: notificationStyle.$2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    notification.actorFullName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notification.type),
                  trailing: Text(
                    NubarDateUtils.timeAgo(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(realtimeNotificationsProvider.notifier)
                          .markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
