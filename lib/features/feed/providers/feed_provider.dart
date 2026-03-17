import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// Post model
class PostModel {
  final String id;
  final String userId;
  final String? content;
  final String type;
  final List<String>? mediaUrls;
  final String? thumbnailUrl;
  final String? communityId;
  final String? originalPostId;
  final bool isRepost;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int bookmarkCount;
  final String language;
  final bool isDeleted;
  final DateTime createdAt;
  // Joined user data
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;

  const PostModel({
    required this.id,
    required this.userId,
    this.content,
    this.type = 'text',
    this.mediaUrls,
    this.thumbnailUrl,
    this.communityId,
    this.originalPostId,
    this.isRepost = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.bookmarkCount = 0,
    this.language = 'ku',
    this.isDeleted = false,
    required this.createdAt,
    this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String?,
      type: json['type'] as String? ?? 'text',
      mediaUrls: (json['media_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      communityId: json['community_id'] as String?,
      originalPostId: json['original_post_id'] as String?,
      isRepost: json['is_repost'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      repostCount: json['repost_count'] as int? ?? 0,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
      language: json['language'] as String? ?? 'ku',
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: user?['username'] as String?,
      authorFullName: user?['full_name'] as String?,
      authorAvatarUrl: user?['avatar_url'] as String?,
    );
  }
}

// Comment model
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final int likeCount;
  final bool isDeleted;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    this.likeCount = 0,
    this.isDeleted = false,
    required this.createdAt,
    this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: user?['username'] as String?,
      authorFullName: user?['full_name'] as String?,
      authorAvatarUrl: user?['avatar_url'] as String?,
    );
  }
}

// Feed provider - fetches paginated posts
final feedProvider = FutureProvider.family<List<PostModel>, int>((ref, page) async {
  final from = page * AppConstants.defaultPageSize;
  final to = from + AppConstants.defaultPageSize - 1;

  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select('*, users!posts_user_id_fkey(username, full_name, avatar_url)')
      .eq('is_deleted', false)
      .order('created_at', ascending: false)
      .range(from, to);

  return (response as List)
      .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

// Post detail provider
final postDetailProvider =
    FutureProvider.family<PostModel?, String>((ref, postId) async {
  final response = await SupabaseService.from(SupabaseConstants.postsTable)
      .select('*, users!posts_user_id_fkey(username, full_name, avatar_url)')
      .eq('id', postId)
      .maybeSingle();

  if (response == null) return null;
  return PostModel.fromJson(response);
});

// Comments for a post
final commentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final response = await SupabaseService.from(SupabaseConstants.commentsTable)
      .select('*, users!comments_user_id_fkey(username, full_name, avatar_url)')
      .eq('post_id', postId)
      .eq('is_deleted', false)
      .order('created_at', ascending: true);

  return (response as List)
      .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

// Check if current user liked a post
final isLikedProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return false;

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return false;

  final response = await SupabaseService.from(SupabaseConstants.likesTable)
      .select()
      .eq('user_id', profile['id'])
      .eq('post_id', postId)
      .maybeSingle();

  return response != null;
});

// Check if current user bookmarked a post
final isBookmarkedProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return false;

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return false;

  final response = await SupabaseService.from(SupabaseConstants.bookmarksTable)
      .select()
      .eq('user_id', profile['id'])
      .eq('post_id', postId)
      .maybeSingle();

  return response != null;
});

// Feed actions
final feedActionsProvider =
    StateNotifierProvider<FeedActionsNotifier, AsyncValue<void>>((ref) {
  return FeedActionsNotifier(ref);
});

class FeedActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  FeedActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<String?> _getCurrentUserId() async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) return null;

    final profile = await SupabaseService.from(SupabaseConstants.usersTable)
        .select('id')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    return profile?['id'] as String?;
  }

  Future<void> likePost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.likesTable).insert({
        'user_id': userId,
        'post_id': postId,
      });

      _ref.invalidate(isLikedProvider(postId));
      _ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> unlikePost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.likesTable)
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);

      _ref.invalidate(isLikedProvider(postId));
      _ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> bookmarkPost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.bookmarksTable).insert({
        'user_id': userId,
        'post_id': postId,
      });

      _ref.invalidate(isBookmarkedProvider(postId));
    });
  }

  Future<void> unbookmarkPost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.bookmarksTable)
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);

      _ref.invalidate(isBookmarkedProvider(postId));
    });
  }

  Future<void> addComment(String postId, String content) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.commentsTable).insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });

      _ref.invalidate(commentsProvider(postId));
      _ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> repost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      // Check if already reposted
      final existing = await SupabaseService.from(SupabaseConstants.repostsTable)
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) throw Exception('Already reposted');

      await SupabaseService.from(SupabaseConstants.repostsTable).insert({
        'user_id': userId,
        'post_id': postId,
      });

      _ref.invalidate(isRepostedProvider(postId));
      _ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> undoRepost(String postId) async {
    state = await AsyncValue.guard(() async {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception('Not authenticated');

      await SupabaseService.from(SupabaseConstants.repostsTable)
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);

      _ref.invalidate(isRepostedProvider(postId));
      _ref.invalidate(postDetailProvider(postId));
    });
  }

  Future<void> deletePost(String postId) async {
    state = await AsyncValue.guard(() async {
      await SupabaseService.from(SupabaseConstants.postsTable)
          .update({'is_deleted': true}).eq('id', postId);
    });
  }
}

// Check if current user reposted a post
final isRepostedProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final currentUser = SupabaseService.currentUser;
  if (currentUser == null) return false;

  final profile = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id')
      .eq('auth_id', currentUser.id)
      .maybeSingle();

  if (profile == null) return false;

  final response = await SupabaseService.from(SupabaseConstants.repostsTable)
      .select()
      .eq('user_id', profile['id'])
      .eq('post_id', postId)
      .maybeSingle();

  return response != null;
});
