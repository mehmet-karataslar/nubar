import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/post/create/create_post_screen.dart';
import 'package:nubar/features/post/detail/post_detail_screen.dart';

class PostActions extends ConsumerWidget {
  final PostModel post;

  const PostActions({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isLiked = ref.watch(isLikedProvider(post.id));
    final isBookmarked = ref.watch(isBookmarkedProvider(post.id));
    final isReposted = ref.watch(isRepostedProvider(post.id));
    final actions = ref.read(feedActionsProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Comments
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            count: post.commentCount,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: post.id),
                ),
              );
            },
          ),

          // Post reply (new post with reply_to_post_id)
          _ActionButton(
            icon: Icons.reply_rounded,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => CreatePostScreen(
                    replyToPostId: post.id,
                    replyToUsername: post.authorUsername,
                  ),
                ),
              );
            },
          ),

          // Reposts
          _ActionButton(
            icon: Icons.repeat,
            count: post.repostCount,
            color: isReposted.valueOrNull == true
                ? Theme.of(context).colorScheme.primary
                : null,
            onTap: () {
              if (isReposted.valueOrNull == true) {
                actions.undoRepost(post.id);
              } else {
                actions.repost(post.id);
              }
            },
          ),

          // Likes
          _ActionButton(
            icon: isLiked.valueOrNull == true
                ? Icons.favorite
                : Icons.favorite_border,
            count: post.likeCount,
            color: isLiked.valueOrNull == true
                ? Theme.of(context).colorScheme.error
                : null,
            onTap: () {
              if (isLiked.valueOrNull == true) {
                actions.unlikePost(post.id);
              } else {
                actions.likePost(post.id);
              }
            },
          ),

          // Bookmark
          _ActionButton(
            icon: isBookmarked.valueOrNull == true
                ? Icons.bookmark
                : Icons.bookmark_border,
            onTap: () {
              if (isBookmarked.valueOrNull == true) {
                actions.unbookmarkPost(post.id);
              } else {
                actions.bookmarkPost(post.id);
              }
            },
          ),

          // Share
          _ActionButton(
            icon: Icons.share_outlined,
            onTap: () {
              final text = post.content ?? '';
              Share.share(text.isNotEmpty ? text : l10n.appName);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.count, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: iconColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
