class CommunityModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? avatarUrl;
  final String? bannerUrl;
  final bool isPrivate;
  final int memberCount;
  final int postCount;
  final String createdBy;
  final DateTime createdAt;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.avatarUrl,
    this.bannerUrl,
    this.isPrivate = false,
    this.memberCount = 0,
    this.postCount = 0,
    required this.createdBy,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      memberCount: json['member_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'is_private': isPrivate,
      'created_by': createdBy,
    };
  }

  CommunityModel copyWith({
    String? name,
    String? slug,
    String? description,
    String? avatarUrl,
    String? bannerUrl,
    bool? isPrivate,
    int? memberCount,
    int? postCount,
  }) {
    return CommunityModel(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      memberCount: memberCount ?? this.memberCount,
      postCount: postCount ?? this.postCount,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}

class CommunityMemberModel {
  final String id;
  final String communityId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const CommunityMemberModel({
    required this.id,
    required this.communityId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
