import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String? actorId;
  final String? postId;
  final String? commentId;
  final bool isRead;
  final DateTime createdAt;
  // Joined data
  final String? actorUsername;
  final String? actorFullName;
  final String? actorAvatarUrl;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.actorId,
    this.postId,
    this.commentId,
    this.isRead = false,
    required this.createdAt,
    this.actorUsername,
    this.actorFullName,
    this.actorAvatarUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      actorId: json['actor_id'] as String?,
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorUsername: actor?['username'] as String?,
      actorFullName: actor?['full_name'] as String?,
      actorAvatarUrl: actor?['avatar_url'] as String?,
    );
  }
}

final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return [];

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return [];

  final response =
      await SupabaseService.from(SupabaseConstants.notificationsTable)
          .select(
              '*, actor:users!notifications_actor_id_fkey(username, full_name, avatar_url)')
          .eq('user_id', profile['id'])
          .order('created_at', ascending: false)
          .limit(50);

  return (response as List)
      .map(
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications.where((n) => !n.isRead).length;
});

final notificationActionsProvider =
    StateNotifierProvider<NotificationActionsNotifier, AsyncValue<void>>(
        (ref) {
  return NotificationActionsNotifier(ref);
});

class NotificationActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  NotificationActionsNotifier(this._ref)
      : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    state = await AsyncValue.guard(() async {
      await SupabaseService.from(SupabaseConstants.notificationsTable)
          .update({'is_read': true}).eq('id', notificationId);

      _ref.invalidate(notificationsProvider);
    });
  }

  Future<void> markAllAsRead() async {
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) return;

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (profile == null) return;

      await SupabaseService.from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', profile['id'])
          .eq('is_read', false);

      _ref.invalidate(notificationsProvider);
    });
  }
}
