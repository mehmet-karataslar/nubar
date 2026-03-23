import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/profile/screens/profile_screen.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';
import 'package:nubar/shared/widgets/nubar_empty_state.dart';

/// Model for follower/following user info
class FollowUserInfo {
  final String userId;
  final String username;
  final String fullName;
  final String? avatarUrl;

  const FollowUserInfo({
    required this.userId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });
}

/// Fetch followers for a given user
final followersListProvider = FutureProvider.family<List<FollowUserInfo>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.followsTable)
      .select(
        'follower_id, users!follows_follower_id_fkey(id, username, full_name, avatar_url)',
      )
      .eq('following_id', userId);

  return (response as List).map((json) {
    final data = json as Map<String, dynamic>;
    final user = data['users'] as Map<String, dynamic>;
    return FollowUserInfo(
      userId: user['id'] as String,
      username: user['username'] as String? ?? '',
      fullName: user['full_name'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String?,
    );
  }).toList();
});

/// Fetch following for a given user
final followingListProvider = FutureProvider.family<List<FollowUserInfo>, String>((
  ref,
  userId,
) async {
  final response = await SupabaseService.from(SupabaseConstants.followsTable)
      .select(
        'following_id, users!follows_following_id_fkey(id, username, full_name, avatar_url)',
      )
      .eq('follower_id', userId);

  return (response as List).map((json) {
    final data = json as Map<String, dynamic>;
    final user = data['users'] as Map<String, dynamic>;
    return FollowUserInfo(
      userId: user['id'] as String,
      username: user['username'] as String? ?? '',
      fullName: user['full_name'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String?,
    );
  }).toList();
});

class FollowersScreen extends ConsumerWidget {
  final String userId;
  final bool showFollowers;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.showFollowers = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      initialIndex: showFollowers ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(showFollowers ? l10n.followers : l10n.following),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.followers),
              Tab(text: l10n.following),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FollowList(
              provider: followersListProvider(userId),
              emptyIcon: Icons.people_outline,
              emptyText: l10n.noFollowers,
            ),
            _FollowList(
              provider: followingListProvider(userId),
              emptyIcon: Icons.person_add_disabled,
              emptyText: l10n.noFollowing,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowList extends ConsumerWidget {
  final FutureProvider<List<FollowUserInfo>> provider;
  final IconData emptyIcon;
  final String emptyText;

  const _FollowList({
    required this.provider,
    required this.emptyIcon,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(provider);

    return listAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) =>
          Center(child: Text(AppLocalizations.of(context)!.error)),
      data: (users) {
        if (users.isEmpty) {
          return NubarEmptyState(icon: emptyIcon, title: emptyText);
        }

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: NubarAvatar(
                imageUrl: user.avatarUrl,
                radius: 22,
                fallbackText: user.fullName,
              ),
              title: Text(
                user.fullName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('@${user.username}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: user.userId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
