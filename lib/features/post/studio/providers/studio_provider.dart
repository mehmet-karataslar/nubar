import 'dart:io';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/core/constants/backblaze_constants.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/core/utils/current_user_profile.dart';
import 'package:nubar/shared/services/backblaze_service.dart';
import 'package:nubar/shared/services/supabase_service.dart';

final studioProvider = StateNotifierProvider<StudioNotifier, AsyncValue<void>>((
  ref,
) {
  return StudioNotifier();
});

class StudioNotifier extends StateNotifier<AsyncValue<void>> {
  StudioNotifier() : super(const AsyncValue.data(null));

  Future<void> createArticle({
    required String title,
    String? subtitle,
    required String plainContent,
    required String contentDelta,
    File? coverImage,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();

      final metadata = {
        'article_title': title,
        if (subtitle != null && subtitle.trim().isNotEmpty)
          'article_subtitle': subtitle,
        'rich_delta': jsonDecode(contentDelta),
        'is_article': true,
      };

      // Create post first to get ID
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': plainContent,
                'type': 'article',
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      if (coverImage != null) {
        final extension = _extensionOf(coverImage.path, fallback: 'jpg');
        final filename =
            '${DateTime.now().millisecondsSinceEpoch}_cover.$extension';
        final path = BackblazeConstants.postImagePath(postId, filename);

        final url = await BackblazeService.uploadFile(
          file: coverImage,
          path: path,
          contentType: _contentTypeForImage(extension),
        );

        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({
              'media_urls': [url],
            })
            .eq('id', postId);
      }
    });
  }

  Future<void> createPdfHub({
    required String title,
    required String author,
    String? pageCount,
    required String summary,
    required File coverImage,
    required File pdfFile,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();

      final metadata = {
        'book_title': title,
        'book_author': author,
        if (pageCount != null && pageCount.isNotEmpty) 'page_count': pageCount,
        'is_pdf_hub': true,
      };

      // Insert with safe temporary type to satisfy media check constraint.
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': summary,
                'type': 'text',
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      try {
        final coverExt = _extensionOf(coverImage.path, fallback: 'jpg');
        final coverFilename =
            '${DateTime.now().millisecondsSinceEpoch}_cover.$coverExt';
        final coverPath = BackblazeConstants.postImagePath(
          postId,
          coverFilename,
        );
        final coverUrl = await BackblazeService.uploadFile(
          file: coverImage,
          path: coverPath,
          contentType: _contentTypeForImage(coverExt),
        );

        _validateFileSize(pdfFile, AppConstants.maxPdfSizeMB);
        final pdfFilename =
            '${DateTime.now().millisecondsSinceEpoch}_document.pdf';
        final pdfPath = BackblazeConstants.postPdfPath(postId, pdfFilename);
        final pdfUrl = await BackblazeService.uploadFile(
          file: pdfFile,
          path: pdfPath,
          contentType: 'application/pdf',
        );

        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({
              'type': 'pdf',
              'media_urls': [pdfUrl],
              'thumbnail_url': coverUrl,
            })
            .eq('id', postId);
      } catch (e) {
        await SupabaseService.from(
          SupabaseConstants.postsTable,
        ).delete().eq('id', postId);
        rethrow;
      }
    });
  }

  Future<void> createThread({
    required List<String> threadTexts,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();

      final metadata = {'is_thread': true, 'thread_parts': threadTexts};

      // Store the first part as the main content for compatibility, and the rest in metadata
      await SupabaseService.from(SupabaseConstants.postsTable).insert({
        'user_id': userId,
        'content': threadTexts.first,
        'type': 'thread',
        'language': language,
        'metadata': metadata,
      });
    });
  }

  Future<void> createVoiceNote({
    required String title,
    required String description,
    File? backgroundImage,
    required File audioFile,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();

      final metadata = {'voice_title': title, 'is_voice_note': true};

      // Insert with safe temporary type to satisfy media check constraint.
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': description,
                'type': 'text',
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      try {
        _validateFileSize(audioFile, AppConstants.maxVideoSizeMB);
        final audioExt = _extensionOf(audioFile.path, fallback: 'm4a');
        final audioFilename =
            '${DateTime.now().millisecondsSinceEpoch}_audio.$audioExt';
        final audioPath = BackblazeConstants.postVideoPath(
          postId,
          audioFilename,
        );
        final audioUrl = await BackblazeService.uploadFile(
          file: audioFile,
          path: audioPath,
          contentType: _contentTypeForAudio(audioExt),
        );

        String? bgUrl;
        if (backgroundImage != null) {
          final bgExt = _extensionOf(backgroundImage.path, fallback: 'jpg');
          final bgFilename =
              '${DateTime.now().millisecondsSinceEpoch}_bg.$bgExt';
          final bgPath = BackblazeConstants.postImagePath(postId, bgFilename);
          bgUrl = await BackblazeService.uploadFile(
            file: backgroundImage,
            path: bgPath,
            contentType: _contentTypeForImage(bgExt),
          );
        }

        await SupabaseService.from(SupabaseConstants.postsTable)
            .update({
              'type': 'voice',
              'media_urls': [audioUrl],
              if (bgUrl != null) 'thumbnail_url': bgUrl,
            })
            .eq('id', postId);
      } catch (e) {
        await SupabaseService.from(
          SupabaseConstants.postsTable,
        ).delete().eq('id', postId);
        rethrow;
      }
    });
  }

  Future<void> createQuiz({
    required String question,
    required List<String> options,
    required int correctOptionIndex,
    String? explanation,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');
      final userId = await CurrentUserProfile.getOrCreateId();
      final metadata = {
        'quiz_question': question,
        'quiz_options': options,
        'quiz_correct_index': correctOptionIndex,
        if (explanation != null && explanation.trim().isNotEmpty)
          'quiz_explanation': explanation.trim(),
      };

      await SupabaseService.from(SupabaseConstants.postsTable).insert({
        'user_id': userId,
        'content': question,
        'type': 'quiz',
        'language': language,
        'metadata': metadata,
      });
    });
  }

  String _extensionOf(String path, {required String fallback}) {
    final fileName = path.split('/').last.split('\\').last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return fallback;
    return fileName.substring(dotIndex + 1).toLowerCase();
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

  String _contentTypeForAudio(String extension) {
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'm4a':
      default:
        return 'audio/mp4';
    }
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
}
