import 'dart:io';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/core/constants/backblaze_constants.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/core/utils/current_user_profile.dart';
import 'package:nubar/shared/services/backblaze_service.dart';
import 'package:nubar/shared/services/supabase_service.dart';

final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, AsyncValue<void>>((ref) {
      return CreatePostNotifier();
    });

class CreatePostNotifier extends StateNotifier<AsyncValue<void>> {
  CreatePostNotifier() : super(const AsyncValue.data(null));

  Future<void> updatePostContent({
    required String postId,
    required String content,
    String? richDeltaJson,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final existing = await SupabaseService.from(
        SupabaseConstants.postsTable,
      ).select('metadata').eq('id', postId).maybeSingle();

      final metadata = Map<String, dynamic>.from(
        (existing?['metadata'] as Map<String, dynamic>?) ?? const {},
      );
      if (richDeltaJson != null && richDeltaJson.isNotEmpty) {
        metadata['rich_delta'] = jsonDecode(richDeltaJson);
      }

      await SupabaseService.from(SupabaseConstants.postsTable)
          .update({'content': content.trim(), 'metadata': metadata})
          .eq('id', postId);
    });
  }

  Future<void> createPost({
    required String content,
    String type = 'text',
    String? replyToPostId,
    List<File>? images,
    File? video,
    File? pdf,
    String? pdfFileName,
    String? pollQuestion,
    List<String>? pollOptions,
    int? pollHours,
    String? richDeltaJson,
    String? communityId,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();

      final resolvedType = _resolveType(
        explicitType: type,
        images: images,
        video: video,
        pdf: pdf,
        pollOptions: pollOptions,
      );

      final metadata = <String, dynamic>{};
      if (resolvedType == 'pdf' &&
          pdfFileName != null &&
          pdfFileName.isNotEmpty) {
        metadata['pdf_file_name'] = pdfFileName;
      }
      if (resolvedType == 'poll' &&
          pollQuestion != null &&
          pollQuestion.trim().isNotEmpty) {
        metadata['poll_question'] = pollQuestion.trim();
      }
      if (richDeltaJson != null && richDeltaJson.isNotEmpty) {
        metadata['rich_delta'] = jsonDecode(richDeltaJson);
      }

      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': content,
                'type': resolvedType,
                'language': language,
                if (replyToPostId != null) 'reply_to_post_id': replyToPostId,
                if (communityId != null) 'community_id': communityId,
                if (metadata.isNotEmpty) 'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      if (resolvedType == 'image' && images != null && images.isNotEmpty) {
        final mediaUrls = <String>[];
        for (var i = 0; i < images.length; i++) {
          final image = images[i];
          final extension = _extensionOf(image.path, fallback: 'jpg');
          final filename =
              '${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
          final path = BackblazeConstants.postImagePath(postId, filename);
          final url = await BackblazeService.uploadFile(
            file: image,
            path: path,
            contentType: _contentTypeForImage(extension),
          );
          mediaUrls.add(url);
        }
        await SupabaseService.from(
          SupabaseConstants.postsTable,
        ).update({'media_urls': mediaUrls}).eq('id', postId);
      }

      if (resolvedType == 'video' && video != null) {
        _validateFileSize(video, AppConstants.maxVideoSizeMB);
        final extension = _extensionOf(video.path, fallback: 'mp4');
        final filename = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final path = BackblazeConstants.postVideoPath(postId, filename);
        final url = await BackblazeService.uploadFile(
          file: video,
          path: path,
          contentType: _contentTypeForVideo(extension),
        );
        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({
              'media_urls': [url],
            })
            .eq('id', postId);
      }

      if (resolvedType == 'pdf' && pdf != null) {
        _validateFileSize(pdf, AppConstants.maxPdfSizeMB);
        final extension = _extensionOf(pdf.path, fallback: 'pdf');
        final filename = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final path = BackblazeConstants.postPdfPath(postId, filename);
        final url = await BackblazeService.uploadFile(
          file: pdf,
          path: path,
          contentType: 'application/pdf',
        );
        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({
              'media_urls': [url],
            })
            .eq('id', postId);
      }

      if (resolvedType == 'poll' &&
          pollOptions != null &&
          pollOptions.length >= 2) {
        final options = <String, dynamic>{};
        for (var i = 0; i < pollOptions.length; i++) {
          options['option_$i'] = {'text': pollOptions[i], 'count': 0};
        }
        await SupabaseService.from(SupabaseConstants.pollsTable).insert({
          'post_id': postId,
          'question': pollQuestion?.trim().isNotEmpty == true
              ? pollQuestion!.trim()
              : content.trim(),
          'options': options,
          if (pollHours != null)
            'ends_at': DateTime.now()
                .add(Duration(hours: pollHours))
                .toIso8601String(),
        });
      }
    });
  }

  String _resolveType({
    required String explicitType,
    required List<File>? images,
    required File? video,
    required File? pdf,
    required List<String>? pollOptions,
  }) {
    if (images != null && images.isNotEmpty) return 'image';
    if (video != null) return 'video';
    if (pdf != null) return 'pdf';
    if (pollOptions != null && pollOptions.length >= 2) return 'poll';
    return explicitType;
  }

  String _extensionOf(String path, {required String fallback}) {
    final fileName = path.split('/').last.split('\\').last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return fallback;
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  void _validateFileSize(File file, int maxSizeMb) {
    final bytes = file.lengthSync();
    final maxBytes = maxSizeMb * 1024 * 1024;
    if (bytes > maxBytes) {
      throw Exception(
        'File is too large. Maximum allowed size is $maxSizeMb MB.',
      );
    }
  }

  String _contentTypeForImage(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _contentTypeForVideo(String extension) {
    switch (extension) {
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'video/mp4';
    }
  }
}
