import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  factory NotificationModel.fromRealtimePayload(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      actorId: json['actor_id'] as String?,
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ============================================================
// REALTIME NOTIFICATIONS
// ============================================================
final realtimeNotificationsProvider = StateNotifierProvider<
    RealtimeNotificationsNotifier,
    AsyncValue<List<NotificationModel>>>(
  (ref) => RealtimeNotificationsNotifier(ref),
);

class RealtimeNotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  RealtimeChannel? _channel;
  String? _currentUserId;

  RealtimeNotificationsNotifier(this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _fetchNotifications();
    _subscribeToRealtime();
  }

  Future<void> _fetchNotifications() async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (profile == null) {
        state = const AsyncValue.data([]);
        return;
      }

      _currentUserId = profile['id'] as String;

      final response =
          await SupabaseService.from(SupabaseConstants.notificationsTable)
              .select(
                  '*, actor:users!notifications_actor_id_fkey(username, full_name, avatar_url)')
              .eq('user_id', _currentUserId!)
              .order('created_at', ascending: false)
              .limit(50);

      if (!mounted) return;
      state = AsyncValue.data(
        (response as List)
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void _subscribeToRealtime() {
    if (_currentUserId == null) return;

    _channel =
        SupabaseService.channel('notifications:$_currentUserId');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.notificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) {
            _onNewNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  void _onNewNotification(Map<String, dynamic> newRecord) {
    if (!mounted) return;

    final notification =
        NotificationModel.fromRealtimePayload(newRecord);
    final current = state.valueOrNull ?? [];

    // Prevent duplicates
    if (current.any((n) => n.id == notification.id)) return;

    // Prepend (newest first)
    state = AsyncValue.data([notification, ...current]);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.from(SupabaseConstants.notificationsTable)
          .update({'is_read': true}).eq('id', notificationId);

      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              actorId: n.actorId,
              postId: n.postId,
              commentId: n.commentId,
              isRead: true,
              createdAt: n.createdAt,
              actorUsername: n.actorUsername,
              actorFullName: n.actorFullName,
              actorAvatarUrl: n.actorAvatarUrl,
            );
          }
          return n;
        }).toList(),
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await SupabaseService.from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', _currentUserId!)
          .eq('is_read', false);

      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            type: n.type,
            actorId: n.actorId,
            postId: n.postId,
            commentId: n.commentId,
            isRead: true,
            createdAt: n.createdAt,
            actorUsername: n.actorUsername,
            actorFullName: n.actorFullName,
            actorAvatarUrl: n.actorAvatarUrl,
          );
        }).toList(),
      );
    } catch (_) {}
  }

  Future<void> refresh() async {
    await _fetchNotifications();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// Unread count derived from realtime notifications
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(realtimeNotificationsProvider);
  return notificationsAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0;
});
