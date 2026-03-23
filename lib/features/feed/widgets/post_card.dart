import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/date_utils.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/feed/widgets/post_actions.dart';
import 'package:nubar/features/post/detail/post_detail_screen.dart';
import 'package:nubar/features/profile/screens/profile_screen.dart';
import 'package:nubar/features/profile/providers/block_provider.dart';
import 'package:nubar/features/report/report_dialog.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: post.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  NubarAvatar(
                    imageUrl: post.authorAvatarUrl,
                    radius: 20,
                    fallbackText: post.authorFullName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(userId: post.userId),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorFullName ?? '',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@${post.authorUsername ?? ''} · ${NubarDateUtils.timeAgo(post.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (sheetContext) => Consumer(
                          builder: (context, sheetRef, _) {
                            final l10n = AppLocalizations.of(context)!;
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline),
                                    title: Text(l10n.delete),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      ref
                                          .read(feedActionsProvider.notifier)
                                          .deletePost(post.id);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.flag_outlined),
                                    title: Text(l10n.report),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      showReportDialog(
                                        context,
                                        ref,
                                        postId: post.id,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.block),
                                    title: Text(l10n.blockUser),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      ref
                                          .read(blockActionsProvider.notifier)
                                          .blockUser(post.userId);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.userBlocked),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              if (post.content != null && post.content!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    post.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

              // Media
              if (post.mediaUrls != null && post.mediaUrls!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: post.mediaUrls!.length == 1
                      ? CachedNetworkImage(
                          imageUrl: post.mediaUrls!.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Theme.of(context).colorScheme.surface,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        )
                      : SizedBox(
                          height: 200,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            physics: const NeverScrollableScrollPhysics(),
                            children: post.mediaUrls!
                                .take(4)
                                .map(
                                  (url) => CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),

              const SizedBox(height: 8),

              // Actions
              PostActions(post: post),
            ],
          ),
        ),
      ),
    );
  }
}
