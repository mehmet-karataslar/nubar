class BackblazeConstants {
  BackblazeConstants._();

  static const String bucketName = 'nubara-app';

  // File paths
  static String avatarPath(String userId) => 'avatars/$userId/profile.jpg';
  static String postImagePath(String postId, String filename) =>
      'posts/images/$postId/$filename';
  static String postVideoPath(String postId, String filename) =>
      'posts/videos/$postId/$filename';
  static String postPdfPath(String postId, String filename) =>
      'posts/pdfs/$postId/$filename';
  static String communityAvatarPath(String communityId) =>
      'communities/avatars/$communityId/avatar.jpg';
  static String communityBannerPath(String communityId) =>
      'communities/banners/$communityId/banner.jpg';
  static String videoThumbnailPath(String postId) =>
      'thumbnails/videos/$postId/thumb.jpg';
  static String pdfCoverPath(String postId) =>
      'thumbnails/pdfs/$postId/cover.jpg';
}
