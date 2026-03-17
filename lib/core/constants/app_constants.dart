class AppConstants {
  AppConstants._();

  static const String appName = 'Nûbar';
  static const String appTagline = 'Kurdish Digital Platform';

  // Pagination
  static const int defaultPageSize = 20;
  static const int commentsPageSize = 15;
  static const int searchPageSize = 20;

  // Media limits
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxPdfSizeMB = 50;
  static const int maxImagesPerPost = 4;

  // Text limits
  static const int maxPostLength = 1000;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 160;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 8;

  // Supported media types
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedVideoTypes = ['mp4', 'mov', 'avi'];
  static const List<String> supportedPdfTypes = ['pdf'];
}
