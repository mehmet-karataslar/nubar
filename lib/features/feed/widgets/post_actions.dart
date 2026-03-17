import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';

class PostActions extends ConsumerWidget {
  final PostModel post;

  const PostActions({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(isLikedProvider(post.id));
    final isBookmarked = ref.watch(isBookmarkedProvider(post.id));
    final actions = ref.read(feedActionsProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Comments
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          count: post.commentCount,
          onTap: () {
            // Navigate to post detail for comments
          },
        ),

        // Reposts
        _ActionButton(
          icon: Icons.repeat,
          count: post.repostCount,
          onTap: () {
            // TODO: Repost functionality
          },
        ),

        // Likes
        _ActionButton(
          icon: isLiked.valueOrNull == true
              ? Icons.favorite
              : Icons.favorite_border,
          count: post.likeCount,
          color: isLiked.valueOrNull == true ? Colors.red : null,
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
            // TODO: Share functionality
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.count,
    this.color,
    this.onTap,
  });

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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: iconColor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
