import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/auth/models/auth_model.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/profile/providers/block_provider.dart';
import 'package:nubar/features/profile/providers/badge_provider.dart';
import 'package:nubar/features/profile/providers/profile_provider.dart';
import 'package:nubar/features/profile/widgets/badge_display.dart';
import 'package:nubar/features/profile/widgets/profile_likes_tab.dart';
import 'package:nubar/features/profile/widgets/profile_media_tab.dart';
import 'package:nubar/features/profile/widgets/profile_photos_tab.dart';
import 'package:nubar/features/profile/widgets/profile_posts_tab.dart';
import 'package:nubar/features/profile/widgets/profile_replies_tab.dart';
import 'package:nubar/features/profile/widgets/profile_tabs_header.dart';
import 'package:nubar/features/profile/screens/edit_profile_screen.dart';
import 'package:nubar/features/profile/screens/followers_screen.dart';
import 'package:nubar/features/settings/screens/settings_screen.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final isFollowingAsync = ref.watch(isFollowingProvider(widget.userId));
    final isBlockedAsync = ref.watch(isBlockedProvider(widget.userId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          if (currentUserAsync.valueOrNull?.id == widget.userId)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          if (currentUserAsync.valueOrNull?.id != widget.userId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'block') {
                  final isBlocked = isBlockedAsync.valueOrNull ?? false;
                  if (isBlocked) {
                    ref
                        .read(blockActionsProvider.notifier)
                        .unblockUser(widget.userId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.userUnblocked)));
                  } else {
                    ref
                        .read(blockActionsProvider.notifier)
                        .blockUser(widget.userId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.userBlocked)));
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(
                        (isBlockedAsync.valueOrNull ?? false)
                            ? Icons.lock_open
                            : Icons.block,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (isBlockedAsync.valueOrNull ?? false)
                            ? l10n.unblock
                            : l10n.block,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.error),
              const SizedBox(height: 8),
              NubarButton(
                text: l10n.retry,
                onPressed: () =>
                    ref.invalidate(userProfileProvider(widget.userId)),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.noResults));
          }

          final isOwnProfile =
              currentUserAsync.valueOrNull?.id == widget.userId;
          final isBlocked = isBlockedAsync.valueOrNull ?? false;

          return DefaultTabController(
            length: 5,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      userId: widget.userId,
                      isOwnProfile: isOwnProfile,
                      isBlocked: isBlocked,
                      user: user,
                      isFollowingAsync: isFollowingAsync,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedTabBarDelegate(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.outline.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            bottom: BorderSide(
                              color: colorScheme.outline.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                        ),
                        child: ProfileTabsHeader(
                          tabs: [
                            Tab(text: l10n.posts),
                            Tab(text: l10n.replies),
                            Tab(text: l10n.media),
                            Tab(text: l10n.photos),
                            Tab(text: l10n.likes),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  ProfilePostsTab(userId: widget.userId),
                  ProfileRepliesTab(userId: widget.userId),
                  ProfileMediaTab(userId: widget.userId),
                  ProfilePhotosTab(userId: widget.userId),
                  ProfileLikesTab(userId: widget.userId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LevelStars extends ConsumerWidget {
  final String userId;

  const _LevelStars({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(userLevelProvider(userId));

    return levelAsync.when(
      data: (level) {
        if (level <= 1) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            level,
            (_) => Icon(
              Icons.star,
              size: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final String userId;
  final UserModel user;
  final bool isOwnProfile;
  final bool isBlocked;
  final AsyncValue<bool> isFollowingAsync;

  const _ProfileHeader({
    required this.userId,
    required this.user,
    required this.isOwnProfile,
    required this.isBlocked,
    required this.isFollowingAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          NubarAvatar(
            imageUrl: user.avatarUrl,
            radius: 50,
            fallbackText: user.fullName,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user.verified)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: Icon(
                    Icons.verified,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: _LevelStars(userId: userId),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 10),
            child: BadgeDisplay(userId: userId),
          ),
          if (user.location != null || user.website != null) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 8,
              children: [
                if (user.location != null)
                  _MetaItem(
                    icon: Icons.location_on_outlined,
                    label: user.location!,
                  ),
                if (user.website != null)
                  _MetaItem(icon: Icons.link, label: user.website!),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatColumn(count: user.postCount, label: l10n.posts),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FollowersScreen(userId: userId, showFollowers: true),
                    ),
                  );
                },
                child: _StatColumn(
                  count: user.followerCount,
                  label: l10n.followers,
                ),
              ),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FollowersScreen(userId: userId, showFollowers: false),
                    ),
                  );
                },
                child: _StatColumn(
                  count: user.followingCount,
                  label: l10n.following,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isOwnProfile
              ? NubarButton(
                  text: l10n.editProfile,
                  isOutlined: true,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );
                  },
                )
              : isBlocked
              ? NubarButton(
                  text: l10n.blocked,
                  isOutlined: true,
                  width: double.infinity,
                  onPressed: () {
                    ref.read(blockActionsProvider.notifier).unblockUser(userId);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.userUnblocked)));
                  },
                )
              : isFollowingAsync.when(
                  data: (isFollowing) => NubarButton(
                    text: isFollowing ? l10n.unfollow : l10n.follow,
                    isOutlined: isFollowing,
                    width: double.infinity,
                    onPressed: () {
                      if (isFollowing) {
                        ref
                            .read(profileActionsProvider.notifier)
                            .unfollowUser(userId);
                      } else {
                        ref
                            .read(profileActionsProvider.notifier)
                            .followUser(userId);
                      }
                    },
                  ),
                  loading: () => const LoadingIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: icon == Icons.link ? colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedTabBarDelegate({required this.child});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
