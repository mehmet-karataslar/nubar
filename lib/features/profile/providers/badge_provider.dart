import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/profile/providers/profile_provider.dart';
import 'package:nubar/shared/services/supabase_service.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String criteriaType;
  final int criteriaValue;
  final DateTime? earnedAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.criteriaType,
    required this.criteriaValue,
    this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    final badge = json['badges'] as Map<String, dynamic>? ?? json;
    return BadgeModel(
      id: badge['id'] as String,
      name: badge['name'] as String,
      description: badge['description'] as String? ?? '',
      icon: badge['icon'] as String,
      criteriaType: badge['criteria_type'] as String,
      criteriaValue: badge['criteria_value'] as int? ?? 1,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'] as String)
          : null,
    );
  }
}

/// Fetch badges earned by a specific user
final userBadgesProvider =
    FutureProvider.family<List<BadgeModel>, String>((ref, userId) async {
  final response =
      await SupabaseService.from(SupabaseConstants.userBadgesTable)
          .select('*, badges(*)')
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

  return (response as List)
      .map((json) => BadgeModel.fromJson(json as Map<String, dynamic>))
      .toList();
});

/// Compute user level based on post_count and follower_count
final userLevelProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final user = await ref.watch(userProfileProvider(userId).future);
  if (user == null) return 1;

  final postCount = user.postCount;
  final followerCount = user.followerCount;

  if (postCount >= 100 && followerCount >= 100) return 5;
  if (postCount >= 50 && followerCount >= 50) return 4;
  if (postCount >= 25 && followerCount >= 25) return 3;
  if (postCount >= 10 && followerCount >= 10) return 2;
  return 1;
});
