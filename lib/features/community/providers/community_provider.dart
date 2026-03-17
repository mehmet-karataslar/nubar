import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/community/models/community_model.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// All communities list
final communitiesProvider = FutureProvider<List<CommunityModel>>((ref) async {
  final response = await SupabaseService.from(SupabaseConstants.communitiesTable)
      .select()
      .order('member_count', ascending: false);

  return (response as List)
      .map((json) => CommunityModel.fromJson(json))
      .toList();
});

// Single community detail
final communityDetailProvider =
    FutureProvider.family<CommunityModel, String>((ref, communityId) async {
  final response = await SupabaseService.from(SupabaseConstants.communitiesTable)
      .select()
      .eq('id', communityId)
      .single();

  return CommunityModel.fromJson(response);
});

// Community members
final communityMembersProvider =
    FutureProvider.family<List<CommunityMemberModel>, String>(
        (ref, communityId) async {
  final response =
      await SupabaseService.from(SupabaseConstants.communityMembersTable)
          .select('*, users(*)')
          .eq('community_id', communityId)
          .order('joined_at');

  return (response as List)
      .map((json) => CommunityMemberModel.fromJson(json))
      .toList();
});

// Check if current user is a member
final isCommunityMemberProvider =
    FutureProvider.family<bool, String>((ref, communityId) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return false;

  final response =
      await SupabaseService.from(SupabaseConstants.communityMembersTable)
          .select()
          .eq('community_id', communityId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

  return response != null;
});

// User's communities
final userCommunitiesProvider = FutureProvider<List<CommunityModel>>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];

  final memberResponse =
      await SupabaseService.from(SupabaseConstants.communityMembersTable)
          .select('community_id')
          .eq('user_id', currentUser.id);

  final communityIds = (memberResponse as List)
      .map((json) => json['community_id'] as String)
      .toList();

  if (communityIds.isEmpty) return [];

  final response = await SupabaseService.from(SupabaseConstants.communitiesTable)
      .select()
      .inFilter('id', communityIds)
      .order('name');

  return (response as List)
      .map((json) => CommunityModel.fromJson(json))
      .toList();
});

// Community actions
final communityActionsProvider =
    Provider<CommunityActions>((ref) => CommunityActions(ref));

class CommunityActions {
  final Ref _ref;
  CommunityActions(this._ref);

  Future<CommunityModel> createCommunity({
    required String name,
    required String slug,
    String? description,
    bool isPrivate = false,
  }) async {
    final currentUser = await _ref.read(currentUserProvider.future);
    if (currentUser == null) throw Exception('Not authenticated');

    final response =
        await SupabaseService.from(SupabaseConstants.communitiesTable)
            .insert({
              'name': name,
              'slug': slug,
              'description': description,
              'is_private': isPrivate,
              'created_by': currentUser.id,
            })
            .select()
            .single();

    final community = CommunityModel.fromJson(response);

    // Add creator as admin
    await SupabaseService.from(SupabaseConstants.communityMembersTable).insert({
      'community_id': community.id,
      'user_id': currentUser.id,
      'role': 'admin',
    });

    _ref.invalidate(communitiesProvider);
    _ref.invalidate(userCommunitiesProvider);
    return community;
  }

  Future<void> joinCommunity(String communityId) async {
    final currentUser = await _ref.read(currentUserProvider.future);
    if (currentUser == null) throw Exception('Not authenticated');

    await SupabaseService.from(SupabaseConstants.communityMembersTable).insert({
      'community_id': communityId,
      'user_id': currentUser.id,
      'role': 'member',
    });

    _ref.invalidate(communityDetailProvider(communityId));
    _ref.invalidate(isCommunityMemberProvider(communityId));
    _ref.invalidate(userCommunitiesProvider);
  }

  Future<void> leaveCommunity(String communityId) async {
    final currentUser = await _ref.read(currentUserProvider.future);
    if (currentUser == null) throw Exception('Not authenticated');

    await SupabaseService.from(SupabaseConstants.communityMembersTable)
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', currentUser.id);

    _ref.invalidate(communityDetailProvider(communityId));
    _ref.invalidate(isCommunityMemberProvider(communityId));
    _ref.invalidate(userCommunitiesProvider);
  }

  Future<void> updateCommunity({
    required String communityId,
    String? name,
    String? description,
    String? avatarUrl,
    String? bannerUrl,
    bool? isPrivate,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (bannerUrl != null) updates['banner_url'] = bannerUrl;
    if (isPrivate != null) updates['is_private'] = isPrivate;

    if (updates.isEmpty) return;

    await SupabaseService.from(SupabaseConstants.communitiesTable)
        .update(updates)
        .eq('id', communityId);

    _ref.invalidate(communityDetailProvider(communityId));
    _ref.invalidate(communitiesProvider);
  }
}
