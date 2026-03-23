import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/feed/widgets/post_card.dart';
import 'package:nubar/features/profile/providers/profile_content_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_empty_state.dart';
import 'package:nubar/shared/widgets/nubar_error_widget.dart';

class ProfileLikesTab extends StatelessWidget {
  final String userId;

  const ProfileLikesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
            tabs: [
              Tab(text: l10n.liked),
              Tab(text: l10n.saved),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _LikesList(
                  userId: userId,
                  isSaved: false,
                  emptyTitle: l10n.noLikedPosts,
                ),
                _LikesList(
                  userId: userId,
                  isSaved: true,
                  emptyTitle: l10n.noSavedPosts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LikesList extends ConsumerWidget {
  final String userId;
  final bool isSaved;
  final String emptyTitle;

  const _LikesList({
    required this.userId,
    required this.isSaved,
    required this.emptyTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = isSaved
        ? ref.watch(profileSavedPostsProvider(userId))
        : ref.watch(profileLikedPostsProvider(userId));

    return asyncPosts.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => NubarErrorWidget(
        onRetry: () => ref.invalidate(
          isSaved
              ? profileSavedPostsProvider(userId)
              : profileLikedPostsProvider(userId),
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return NubarEmptyState(
            icon: isSaved ? Icons.bookmark_outline : Icons.favorite_outline,
            title: emptyTitle,
          );
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }
}
