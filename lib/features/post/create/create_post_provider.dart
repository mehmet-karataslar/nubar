import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/backblaze_constants.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/backblaze_service.dart';
import 'package:nubar/shared/services/supabase_service.dart';

final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, AsyncValue<void>>((ref) {
  return CreatePostNotifier();
});

class CreatePostNotifier extends StateNotifier<AsyncValue<void>> {
  CreatePostNotifier() : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String content,
    String type = 'text',
    List<File>? images,
    String? communityId,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final profile = await SupabaseService.from(SupabaseConstants.usersTable)
          .select('id')
          .eq('auth_id', currentUser.id)
          .single();

      final userId = profile['id'] as String;

      // Upload images if any
      List<String>? mediaUrls;
      if (images != null && images.isNotEmpty) {
        // Create post first to get the ID
        final postResponse =
            await SupabaseService.from(SupabaseConstants.postsTable)
                .insert({
                  'user_id': userId,
                  'content': content,
                  'type': 'image',
                  'language': language,
                  if (communityId != null) 'community_id': communityId,
                })
                .select('id')
                .single();

        final postId = postResponse['id'] as String;

        mediaUrls = [];
        for (final image in images) {
          final filename =
              '${DateTime.now().millisecondsSinceEpoch}_${mediaUrls.length}.jpg';
          final path = BackblazeConstants.postImagePath(postId, filename);
          final url = await BackblazeService.uploadFile(
            file: image,
            path: path,
            contentType: 'image/jpeg',
          );
          mediaUrls.add(url);
        }

        // Update post with media URLs
        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({'media_urls': mediaUrls}).eq('id', postId);

        return;
      }

      // Text-only post
      await SupabaseService.from(SupabaseConstants.postsTable).insert({
        'user_id': userId,
        'content': content,
        'type': type,
        'language': language,
        if (communityId != null) 'community_id': communityId,
      });
    });
  }
}
