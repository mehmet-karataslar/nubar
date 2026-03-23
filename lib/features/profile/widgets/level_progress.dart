import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/profile/providers/badge_provider.dart';
import 'package:nubar/features/profile/providers/profile_provider.dart';

class LevelProgress extends ConsumerWidget {
  final String userId;

  const LevelProgress({super.key, required this.userId});

  // Level thresholds: {level: (minPosts, minFollowers)}
  static const _thresholds = {
    2: (10, 10),
    3: (25, 25),
    4: (50, 50),
    5: (100, 100),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final levelAsync = ref.watch(userLevelProvider(userId));
    final profileAsync = ref.watch(userProfileProvider(userId));

    return levelAsync.when(
      data: (level) => profileAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final postCount = user.postCount;
          final followerCount = user.followerCount;

          // If max level, show completion
          if (level >= 5) {
            return _buildCard(
              context,
              level: level,
              progress: 1.0,
              label: l10n.maxLevel,
              postCount: postCount,
              followerCount: followerCount,
            );
          }

          // Calculate progress to next level
          final nextLevel = level + 1;
          final threshold = _thresholds[nextLevel]!;
          final postProgress = (postCount / threshold.$1).clamp(0.0, 1.0);
          final followerProgress = (followerCount / threshold.$2).clamp(
            0.0,
            1.0,
          );
          final overallProgress = (postProgress + followerProgress) / 2;

          return _buildCard(
            context,
            level: level,
            progress: overallProgress,
            label: '${l10n.level} $level → $nextLevel',
            postCount: postCount,
            followerCount: followerCount,
            targetPosts: threshold.$1,
            targetFollowers: threshold.$2,
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required int level,
    required double progress,
    required String label,
    required int postCount,
    required int followerCount,
    int? targetPosts,
    int? targetFollowers,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: level stars + label
          Row(
            children: [
              ...List.generate(
                level,
                (_) => Icon(Icons.star, size: 18, color: colorScheme.secondary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),

          // Stats
          if (targetPosts != null && targetFollowers != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.posts}: $postCount/$targetPosts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${l10n.followers}: $followerCount/$targetFollowers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
