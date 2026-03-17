import 'dart:io';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

class BackblazeService {
  static String get cdnUrl => dotenv.env['BACKBLAZE_CDN_URL'] ?? 'https://cdn.nubar.app';

  static Future<String> uploadFile({
    required File file,
    required String path,
    required String contentType,
  }) async {
    // 1. Get signed upload URL from Edge Function
    final response = await SupabaseService.invokeFunction(
      SupabaseConstants.generateUploadUrlFunction,
      body: {
        'path': path,
        'contentType': contentType,
      },
    );

    final data = jsonDecode(response.data as String);
    final uploadUrl = data['uploadUrl'] as String;
    final authToken = data['authorizationToken'] as String;

    // 2. Upload directly to Backblaze
    final fileBytes = await file.readAsBytes();
    await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': authToken,
        'Content-Type': contentType,
        'X-Bz-File-Name': path,
        'X-Bz-Content-Sha1': 'do_not_verify',
      },
      body: fileBytes,
    );

    // 3. Return CDN URL
    return getFileUrl(path);
  }

  static String getFileUrl(String path) => '$cdnUrl/$path';

  static Future<void> deleteFile(String path) async {
    await SupabaseService.invokeFunction(
      SupabaseConstants.deleteFileFunction,
      body: {'path': path},
    );
  }
}
