import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/auth/models/auth_model.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// Fetch a user profile by ID
final userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  final response = await SupabaseService.from(SupabaseConstants.usersTable)
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (response == null) return null;
  return UserModel.fromJson(response);
});

// Check if current user follows a given user
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return false;

  // Get current user's profile ID
  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return false;

  final response = await SupabaseService.from(SupabaseConstants.followsTable)
      .select()
      .eq('follower_id', profile['id'])
      .eq('following_id', userId)
      .maybeSingle();

  return response != null;
});

// Profile actions notifier
final profileActionsProvider =
    StateNotifierProvider<ProfileActionsNotifier, AsyncValue<void>>((ref) {
  return ProfileActionsNotifier(ref);
});

class ProfileActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProfileActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> followUser(String targetUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .single();

      await SupabaseService.from(SupabaseConstants.followsTable).insert({
        'follower_id': profile['id'],
        'following_id': targetUserId,
      });

      _ref.invalidate(isFollowingProvider(targetUserId));
      _ref.invalidate(userProfileProvider(targetUserId));
    });
  }

  Future<void> unfollowUser(String targetUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .single();

      await SupabaseService.from(SupabaseConstants.followsTable)
          .delete()
          .eq('follower_id', profile['id'])
          .eq('following_id', targetUserId);

      _ref.invalidate(isFollowingProvider(targetUserId));
      _ref.invalidate(userProfileProvider(targetUserId));
    });
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? website,
    String? location,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (website != null) updates['website'] = website;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await SupabaseService.from(SupabaseConstants.usersTable)
          .update(updates)
          .eq('id', userId);

      _ref.invalidate(userProfileProvider(userId));
    });
  }
}
