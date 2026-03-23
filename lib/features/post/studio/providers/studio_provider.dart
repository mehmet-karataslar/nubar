import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/backblaze_constants.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
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
    required String contentDelta,
    File? coverImage,
    String language = 'ku',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).single();

      final userId = profile['id'] as String;

      final metadata = {
        'article_title': title,
        if (subtitle != null && subtitle.trim().isNotEmpty)
          'article_subtitle': subtitle,
        'is_article': true,
      };

      // Create post first to get ID
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': contentDelta,
                'type': 'article',
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      if (coverImage != null) {
        final filename = '${DateTime.now().millisecondsSinceEpoch}_cover.jpg';
        final path = BackblazeConstants.postImagePath(postId, filename);

        final url = await BackblazeService.uploadFile(
          file: coverImage,
          path: path,
          contentType: 'image/jpeg',
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

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).single();

      final userId = profile['id'] as String;

      final metadata = {
        'book_title': title,
        'book_author': author,
        if (pageCount != null && pageCount.isNotEmpty) 'page_count': pageCount,
        'is_pdf_hub': true,
      };

      // Create post first to get ID
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content':
                    summary, // The summary will be stored as the main text
                'type': 'pdf', // It's an already supported ENUM type
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      // Upload Cover Image
      final coverFilename =
          '${DateTime.now().millisecondsSinceEpoch}_cover.jpg';
      final coverPath = BackblazeConstants.postImagePath(postId, coverFilename);
      final coverUrl = await BackblazeService.uploadFile(
        file: coverImage,
        path: coverPath,
        contentType: 'image/jpeg',
      );

      // Upload PDF
      final pdfFilename =
          '${DateTime.now().millisecondsSinceEpoch}_document.pdf';
      final pdfPath = BackblazeConstants.postImagePath(postId, pdfFilename);
      final pdfUrl = await BackblazeService.uploadFile(
        file: pdfFile,
        path: pdfPath,
        contentType: 'application/pdf',
      );

      // We store the PDF under media_urls and the cover image in thumbnail_url (or vice versa).
      // Let's store PDF in media_urls[0] and Cover in thumbnail_url
      await SupabaseService.from(SupabaseConstants.postsTable)
          .update({
            'media_urls': [pdfUrl],
            'thumbnail_url': coverUrl,
          })
          .eq('id', postId);
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

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).single();

      final userId = profile['id'] as String;

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

      final profile = await SupabaseService.from(
        SupabaseConstants.usersTable,
      ).select('id').eq('auth_id', currentUser.id).single();

      final userId = profile['id'] as String;

      final metadata = {'voice_title': title, 'is_voice_note': true};

      // Create post first to get ID
      final postResponse =
          await SupabaseService.from(SupabaseConstants.postsTable)
              .insert({
                'user_id': userId,
                'content': description,
                'type': 'voice', // From our new ENUM
                'language': language,
                'metadata': metadata,
              })
              .select('id')
              .single();

      final postId = postResponse['id'] as String;

      // Upload Audio
      final audioFilename =
          '${DateTime.now().millisecondsSinceEpoch}_audio.m4a';
      final audioPath = BackblazeConstants.postImagePath(postId, audioFilename);
      final audioUrl = await BackblazeService.uploadFile(
        file: audioFile,
        path: audioPath,
        contentType: 'audio/mp4', // Gen for m4a/mp3
      );

      // Upload Background Image
      String? bgUrl;
      if (backgroundImage != null) {
        final bgFilename = '${DateTime.now().millisecondsSinceEpoch}_bg.jpg';
        final bgPath = BackblazeConstants.postImagePath(postId, bgFilename);
        bgUrl = await BackblazeService.uploadFile(
          file: backgroundImage,
          path: bgPath,
          contentType: 'image/jpeg',
        );
      }

      await SupabaseService.from(SupabaseConstants.postsTable)
          .update({
            'media_urls': [audioUrl],
            if (bgUrl != null) 'thumbnail_url': bgUrl,
          })
          .eq('id', postId);
    });
  }
}
