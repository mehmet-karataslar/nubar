import 'dart:io';

import 'package:nubar/core/constants/app_constants.dart';

class FileUtils {
  FileUtils._();

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static bool isImage(String path) {
    final ext = getFileExtension(path);
    return AppConstants.supportedImageTypes.contains(ext);
  }

  static bool isVideo(String path) {
    final ext = getFileExtension(path);
    return AppConstants.supportedVideoTypes.contains(ext);
  }

  static bool isPdf(String path) {
    final ext = getFileExtension(path);
    return AppConstants.supportedPdfTypes.contains(ext);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static bool isFileSizeValid(File file, int maxSizeMB) {
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }
}
