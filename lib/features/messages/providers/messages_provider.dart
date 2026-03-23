import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? content;
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;
  // Joined
  final String? senderUsername;
  final String? senderFullName;
  final String? senderAvatarUrl;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.mediaUrl,
    this.isRead = false,
    required this.createdAt,
    this.senderUsername,
    this.senderFullName,
    this.senderAvatarUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: sender?['username'] as String?,
      senderFullName: sender?['full_name'] as String?,
      senderAvatarUrl: sender?['avatar_url'] as String?,
    );
  }

  /// Create from realtime payload (no join data available)
  factory MessageModel.fromRealtimePayload(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// Conversation represents a chat thread with another user
class ConversationModel {
  final String otherUserId;
  final String otherUsername;
  final String otherFullName;
  final String? otherAvatarUrl;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.otherUserId,
    required this.otherUsername,
    required this.otherFullName,
    this.otherAvatarUrl,
    this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

// Helper to get current user's profile ID
Future<String?> _getCurrentProfileId() async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return null;

  final profile = await SupabaseService.from(
    SupabaseConstants.usersTable,
  ).select('id').eq('auth_id', currentUser.id).maybeSingle();

  return profile?['id'] as String?;
}

// ============================================================
// REALTIME CHAT MESSAGES
// ============================================================
final realtimeChatMessagesProvider =
    StateNotifierProvider.family<
      RealtimeChatNotifier,
      AsyncValue<List<MessageModel>>,
      String
    >((ref, otherUserId) => RealtimeChatNotifier(ref, otherUserId));

class RealtimeChatNotifier
    extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final String otherUserId;
  RealtimeChannel? _channel;
  String? _currentUserId;

  RealtimeChatNotifier(Ref ref, this.otherUserId)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _currentUserId = await _getCurrentProfileId();
      if (_currentUserId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      // Initial fetch
      final response = await SupabaseService.from(SupabaseConstants.messagesTable)
          .select(
            '*, sender:users!messages_sender_id_fkey(username, full_name, avatar_url)',
          )
          .or(
            'and(sender_id.eq.$_currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$_currentUserId)',
          )
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      state = AsyncValue.data(messages);

      // Mark incoming messages as read
      _markAsRead();

      // Subscribe to realtime
      _subscribeToRealtime();
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void _subscribeToRealtime() {
    final channelName = 'chat:$_currentUserId:$otherUserId';
    _channel = SupabaseService.channel(channelName);

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'sender_id',
            value: otherUserId,
          ),
          callback: (payload) {
            _onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }

  void _onNewMessage(Map<String, dynamic> newRecord) {
    if (!mounted) return;

    // Only add if this message is part of our conversation
    final senderId = newRecord['sender_id'] as String?;
    final receiverId = newRecord['receiver_id'] as String?;

    final isRelevant =
        (senderId == otherUserId && receiverId == _currentUserId) ||
        (senderId == _currentUserId && receiverId == otherUserId);

    if (!isRelevant) return;

    final message = MessageModel.fromRealtimePayload(newRecord);
    final currentMessages = state.valueOrNull ?? [];

    // Prevent duplicates
    if (currentMessages.any((m) => m.id == message.id)) return;

    state = AsyncValue.data([...currentMessages, message]);

    // Mark as read if from other user
    if (senderId == otherUserId) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    if (_currentUserId == null) return;
    try {
      await SupabaseService.from(SupabaseConstants.messagesTable)
          .update({'is_read': true})
          .eq('sender_id', otherUserId)
          .eq('receiver_id', _currentUserId!)
          .eq('is_read', false);
    } catch (_) {
      // Silently handle - not critical
    }
  }

  /// Called after sending a message to append it optimistically
  void appendSentMessage(MessageModel message) {
    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.any((m) => m.id == message.id)) return;
    state = AsyncValue.data([...currentMessages, message]);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// ============================================================
// CONVERSATIONS LIST (with realtime refresh)
// ============================================================
final conversationsProvider =
    StateNotifierProvider<
      ConversationsNotifier,
      AsyncValue<List<ConversationModel>>
    >((ref) => ConversationsNotifier(ref));

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<ConversationModel>>> {
  RealtimeChannel? _channel;
  String? _currentUserId;

  ConversationsNotifier(Ref ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _fetchConversations();
    _subscribeToRealtime();
  }

  Future<void> _fetchConversations() async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).maybeSingle();

      if (profile == null) {
        state = const AsyncValue.data([]);
        return;
      }

      _currentUserId = profile['id'] as String;

      final response = await SupabaseService.from(SupabaseConstants.messagesTable)
          .select(
            '*, sender:users!messages_sender_id_fkey(id, username, full_name, avatar_url)',
          )
          .or('sender_id.eq.$_currentUserId,receiver_id.eq.$_currentUserId')
          .order('created_at', ascending: false)
          .limit(100);

      // Group by conversation partner
      final conversations = <String, ConversationModel>{};
      for (final msg in response as List) {
        final message = msg as Map<String, dynamic>;
        final senderId = message['sender_id'] as String;
        final receiverId = message['receiver_id'] as String;
        final otherUserId = senderId == _currentUserId ? receiverId : senderId;

        if (!conversations.containsKey(otherUserId)) {
          final sender = message['sender'] as Map<String, dynamic>?;
          final isOtherSender = senderId != _currentUserId;

          conversations[otherUserId] = ConversationModel(
            otherUserId: otherUserId,
            otherUsername: isOtherSender
                ? (sender?['username'] as String? ?? '')
                : '',
            otherFullName: isOtherSender
                ? (sender?['full_name'] as String? ?? '')
                : '',
            otherAvatarUrl: isOtherSender
                ? (sender?['avatar_url'] as String?)
                : null,
            lastMessage: message['content'] as String?,
            lastMessageTime: DateTime.parse(message['created_at'] as String),
            unreadCount:
                (!isOtherSender || (message['is_read'] as bool? ?? false))
                ? 0
                : 1,
          );
        }
      }

      if (!mounted) return;
      state = AsyncValue.data(conversations.values.toList());
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void _subscribeToRealtime() {
    if (_currentUserId == null) return;

    _channel = SupabaseService.channel('conversations:$_currentUserId');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: _currentUserId!,
          ),
          callback: (_) {
            // Refetch conversations when a new message arrives
            _fetchConversations();
          },
        )
        .subscribe();
  }

  Future<void> refresh() async {
    await _fetchConversations();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// ============================================================
// SEND MESSAGE
// ============================================================
final messageActionsProvider =
    StateNotifierProvider<MessageActionsNotifier, AsyncValue<void>>((ref) {
      return MessageActionsNotifier(ref);
    });

class MessageActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MessageActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).single();

      final userId = profile['id'] as String;

      final response =
          await SupabaseService.from(SupabaseConstants.messagesTable)
              .insert({
                'sender_id': userId,
                'receiver_id': receiverId,
                'content': content,
              })
              .select()
              .single();

      // Optimistically append to chat
      final sentMessage = MessageModel(
        id: response['id'] as String,
        senderId: userId,
        receiverId: receiverId,
        content: content,
        createdAt: DateTime.parse(response['created_at'] as String),
      );

      _ref
          .read(realtimeChatMessagesProvider(receiverId).notifier)
          .appendSentMessage(sentMessage);
    });
  }
}
