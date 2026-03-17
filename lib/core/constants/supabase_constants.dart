class SupabaseConstants {
  SupabaseConstants._();

  // Table names
  static const String usersTable = 'users';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String commentLikesTable = 'comment_likes';
  static const String repostsTable = 'reposts';
  static const String bookmarksTable = 'bookmarks';
  static const String followsTable = 'follows';
  static const String communitiesTable = 'communities';
  static const String communityMembersTable = 'community_members';
  static const String notificationsTable = 'notifications';
  static const String messagesTable = 'messages';
  static const String pollsTable = 'polls';
  static const String pollVotesTable = 'poll_votes';
  static const String reportsTable = 'reports';
  static const String hashtagsTable = 'hashtags';
  static const String postHashtagsTable = 'post_hashtags';

  // Edge function names
  static const String generateUploadUrlFunction = 'generate-upload-url';
  static const String generateThumbnailFunction = 'generate-thumbnail';
  static const String sendNotificationFunction = 'send-notification';
  static const String moderateContentFunction = 'moderate-content';
  static const String deleteFileFunction = 'delete-file';
}
