import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/shared/services/supabase_service.dart';

const _profilePostsLimit = 50;
const _postWithAuthorSelect =
    '*, users!posts_user_id_fkey(username, full_name, avatar_url)';

final profilePostsProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select(_postWithAuthorSelect)
      .eq('user_id', userId)
      .eq('is_deleted', false)
      .isFilter('reply_to_post_id', null)
      .order('created_at', ascending: false)
      .limit(_profilePostsLimit);

  return (response as List)
      .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

final profileRepliesProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select(_postWithAuthorSelect)
      .eq('user_id', userId)
      .eq('is_deleted', false)
      .not('reply_to_post_id', 'is', null)
      .order('created_at', ascending: false)
      .limit(_profilePostsLimit);

  return (response as List)
      .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

final profilePhotosProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select(_postWithAuthorSelect)
      .eq('user_id', userId)
      .eq('is_deleted', false)
      .eq('type', 'image')
      .order('created_at', ascending: false)
      .limit(_profilePostsLimit);

  return (response as List)
      .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

final profileMediaProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) async {
  final typedMediaResponse =
      await SupabaseService.from(SupabaseConstants.postsTable)
          .select(_postWithAuthorSelect)
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .inFilter('type', ['image', 'video', 'pdf', 'voice'])
          .order('created_at', ascending: false)
          .limit(_profilePostsLimit);

  final mediaUrlResponse =
      await SupabaseService.from(SupabaseConstants.postsTable)
          .select(_postWithAuthorSelect)
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .not('media_urls', 'is', null)
          .order('created_at', ascending: false)
          .limit(_profilePostsLimit);

  final typedMediaList = typedMediaResponse as List;
  final mediaUrlList = mediaUrlResponse as List;
  final merged = <String, PostModel>{};
  for (final item in [...typedMediaList, ...mediaUrlList]) {
    final post = PostModel.fromJson(item as Map<String, dynamic>);
    merged[post.id] = post;
  }

  final posts = merged.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return posts;
});

final profileLikedPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
      final response = await SupabaseService.from(SupabaseConstants.likesTable)
          .select(
            'created_at, posts!likes_post_id_fkey($_postWithAuthorSelect)',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(_profilePostsLimit);

      return (response as List)
          .map((json) => (json as Map<String, dynamic>)['posts'])
          .whereType<Map<String, dynamic>>()
          .where((post) => post['is_deleted'] == false)
          .map(PostModel.fromJson)
          .toList();
    });

final profileSavedPostsProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.bookmarksTable)
      .select(
        'created_at, posts!bookmarks_post_id_fkey($_postWithAuthorSelect)',
      )
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(_profilePostsLimit);

  return (response as List)
      .map((json) => (json as Map<String, dynamic>)['posts'])
      .whereType<Map<String, dynamic>>()
      .where((post) => post['is_deleted'] == false)
      .map(PostModel.fromJson)
      .toList();
});
