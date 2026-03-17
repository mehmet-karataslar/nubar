import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

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

// Conversations list
final conversationsProvider =
    FutureProvider<List<ConversationModel>>((ref) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return [];

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return [];

  final userId = profile['id'] as String;

  // Get recent messages (sent or received)
  final response = await SupabaseService.from(SupabaseConstants.messagesTable)
      .select(
          '*, sender:users!messages_sender_id_fkey(id, username, full_name, avatar_url)')
      .or('sender_id.eq.$userId,receiver_id.eq.$userId')
      .order('created_at', ascending: false)
      .limit(100);

  // Group by conversation partner
  final conversations = <String, ConversationModel>{};
  for (final msg in response as List) {
    final message = msg as Map<String, dynamic>;
    final senderId = message['sender_id'] as String;
    final receiverId = message['receiver_id'] as String;
    final otherUserId = senderId == userId ? receiverId : senderId;

    if (!conversations.containsKey(otherUserId)) {
      final sender = message['sender'] as Map<String, dynamic>?;
      final isOtherSender = senderId != userId;

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
        lastMessageTime:
            DateTime.parse(message['created_at'] as String),
        unreadCount: (!isOtherSender || (message['is_read'] as bool? ?? false))
            ? 0
            : 1,
      );
    }
  }

  return conversations.values.toList();
});

// Messages in a conversation
final chatMessagesProvider =
    FutureProvider.family<List<MessageModel>, String>((ref, otherUserId) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return [];

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return [];

  final userId = profile['id'] as String;

  final response = await SupabaseService.from(SupabaseConstants.messagesTable)
      .select(
          '*, sender:users!messages_sender_id_fkey(username, full_name, avatar_url)')
      .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
      .order('created_at', ascending: true);

  return (response as List)
      .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

// Send message
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

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .single();

      await SupabaseService.from(SupabaseConstants.messagesTable).insert({
        'sender_id': profile['id'],
        'receiver_id': receiverId,
        'content': content,
      });

      _ref.invalidate(chatMessagesProvider(receiverId));
      _ref.invalidate(conversationsProvider);
    });
  }
}
