import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/profile/providers/profile_provider.dart';
import 'package:nubar/features/profile/providers/block_provider.dart';
import 'package:nubar/features/profile/providers/badge_provider.dart';
import 'package:nubar/features/profile/widgets/badge_display.dart';
import 'package:nubar/features/profile/screens/edit_profile_screen.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider(userId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));
    final isBlockedAsync = ref.watch(isBlockedProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          if (currentUserAsync.valueOrNull?.id != userId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'block') {
                  final isBlocked = isBlockedAsync.valueOrNull ?? false;
                  if (isBlocked) {
                    ref
                        .read(blockActionsProvider.notifier)
                        .unblockUser(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.userUnblocked)),
                    );
                  } else {
                    ref
                        .read(blockActionsProvider.notifier)
                        .blockUser(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.userBlocked)),
                    );
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
                    ref.invalidate(userProfileProvider(userId)),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.noResults));
          }

          final isOwnProfile = currentUserAsync.valueOrNull?.id == userId;
          final isBlocked = isBlockedAsync.valueOrNull ?? false;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Avatar
                NubarAvatar(
                  imageUrl: user.avatarUrl,
                  radius: 50,
                  fallbackText: user.fullName,
                ),
                const SizedBox(height: 16),

                // Name & username
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (user.verified)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6),
                        child: Icon(
                          Icons.verified,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    // Level stars
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: _LevelStars(userId: userId),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 12),

                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                // Badges
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: BadgeDisplay(userId: userId),
                ),

                const SizedBox(height: 8),

                // Location & Website
                if (user.location != null || user.website != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (user.location != null) ...[
                          Icon(Icons.location_on_outlined,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(user.location!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall),
                        ],
                        if (user.location != null && user.website != null)
                          const SizedBox(width: 16),
                        if (user.website != null) ...[
                          Icon(Icons.link,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(user.website!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatColumn(
                      count: user.postCount,
                      label: l10n.posts,
                    ),
                    const SizedBox(width: 32),
                    _StatColumn(
                      count: user.followerCount,
                      label: l10n.followers,
                    ),
                    const SizedBox(width: 32),
                    _StatColumn(
                      count: user.followingCount,
                      label: l10n.following,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: isOwnProfile
                      ? NubarButton(
                          text: l10n.editProfile,
                          isOutlined: true,
                          width: double.infinity,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProfileScreen(user: user),
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
                                ref
                                    .read(blockActionsProvider.notifier)
                                    .unblockUser(userId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(l10n.userUnblocked)),
                                );
                              },
                            )
                          : isFollowingAsync.when(
                              data: (isFollowing) => NubarButton(
                                text:
                                    isFollowing ? l10n.unfollow : l10n.follow,
                                isOutlined: isFollowing,
                                width: double.infinity,
                                onPressed: () {
                                  if (isFollowing) {
                                    ref
                                        .read(
                                            profileActionsProvider.notifier)
                                        .unfollowUser(userId);
                                  } else {
                                    ref
                                        .read(
                                            profileActionsProvider.notifier)
                                        .followUser(userId);
                                  }
                                },
                              ),
                              loading: () => const LoadingIndicator(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                ),
                const SizedBox(height: 24),

                // Divider
                const Divider(),

                // User's posts placeholder
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noPosts,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ],
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
