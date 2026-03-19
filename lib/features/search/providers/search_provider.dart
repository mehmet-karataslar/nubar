import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/auth/models/auth_model.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/profile/providers/block_provider.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results - posts (filtered by blocked users)
final searchPostsProvider =
    FutureProvider<List<PostModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final blockedIds = await ref.watch(blockedUserIdsProvider.future);

  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select('*, users!posts_user_id_fkey(username, full_name, avatar_url)')
      .eq('is_deleted', false)
      .textSearch('content', query)
      .order('created_at', ascending: false)
      .limit(20);

  return (response as List)
      .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
      .where((post) => !blockedIds.contains(post.userId))
      .toList();
});

// Search results - users (filtered by blocked users)
final searchUsersProvider =
    FutureProvider<List<UserModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final blockedIds = await ref.watch(blockedUserIdsProvider.future);

  final response = await SupabaseService.from(SupabaseConstants.usersTable)
      .select()
      .or('username.ilike.%$query%,full_name.ilike.%$query%')
      .limit(20);

  return (response as List)
      .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
      .where((user) => !blockedIds.contains(user.id))
      .toList();
});

// Trending hashtags
final trendingHashtagsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseService.from(SupabaseConstants.hashtagsTable)
      .select()
      .order('post_count', ascending: false)
      .limit(10);

  return (response as List).cast<Map<String, dynamic>>();
});
