import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

/// Set of user IDs that the current user has blocked
final blockedUserIdsProvider = FutureProvider<Set<String>>((ref) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return {};

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return {};

  final response =
      await SupabaseService.from(SupabaseConstants.userBlocksTable)
          .select('blocked_id')
          .eq('blocker_id', profile['id']);

  return (response as List)
      .map((row) => (row as Map<String, dynamic>)['blocked_id'] as String)
      .toSet();
});

/// Check if current user has blocked a specific user
final isBlockedProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final blockedIds = await ref.watch(blockedUserIdsProvider.future);
  return blockedIds.contains(userId);
});

/// Block/unblock actions
final blockActionsProvider =
    StateNotifierProvider<BlockActionsNotifier, AsyncValue<void>>((ref) {
  return BlockActionsNotifier(ref);
});

class BlockActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BlockActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<String?> _getCurrentUserId() async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) return null;

    final profile = await SupabaseService.from(SupabaseConstants.usersTable)
        .select('id')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    return profile?['id'] as String?;
  }

  Future<void> blockUser(String targetUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.userBlocksTable).insert({
        'blocker_id': userId,
        'blocked_id': targetUserId,
      });

      // Also unfollow the blocked user (both directions)
      await SupabaseService.from(SupabaseConstants.followsTable)
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId);

      await SupabaseService.from(SupabaseConstants.followsTable)
          .delete()
          .eq('follower_id', targetUserId)
          .eq('following_id', userId);

      _ref.invalidate(blockedUserIdsProvider);
      _ref.invalidate(isBlockedProvider(targetUserId));
    });
  }

  Future<void> unblockUser(String targetUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.userBlocksTable)
          .delete()
          .eq('blocker_id', userId)
          .eq('blocked_id', targetUserId);

      _ref.invalidate(blockedUserIdsProvider);
      _ref.invalidate(isBlockedProvider(targetUserId));
    });
  }
}
