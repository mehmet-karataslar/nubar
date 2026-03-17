class UserModel {
  final String id;
  final String authId;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String? website;
  final String? location;
  final bool verified;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final String preferredLang;
  final String preferredTheme;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.authId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.website,
    this.location,
    this.verified = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.preferredLang = 'ku',
    this.preferredTheme = 'nubar',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      verified: json['verified'] as bool? ?? false,
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      preferredLang: json['preferred_lang'] as String? ?? 'ku',
      preferredTheme: json['preferred_theme'] as String? ?? 'nubar',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'website': website,
      'location': location,
      'verified': verified,
      'preferred_lang': preferredLang,
      'preferred_theme': preferredTheme,
    };
  }

  UserModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
    String? location,
    String? preferredLang,
    String? preferredTheme,
  }) {
    return UserModel(
      id: id,
      authId: authId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      verified: verified,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      preferredLang: preferredLang ?? this.preferredLang,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      createdAt: createdAt,
    );
  }
}
