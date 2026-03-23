import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/post/detail/post_detail_screen.dart';
import 'package:nubar/features/profile/providers/profile_content_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_empty_state.dart';
import 'package:nubar/shared/widgets/nubar_error_widget.dart';

class ProfileMediaTab extends ConsumerWidget {
  final String userId;

  const ProfileMediaTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mediaAsync = ref.watch(profileMediaProvider(userId));

    return mediaAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => NubarErrorWidget(
        onRetry: () => ref.invalidate(profileMediaProvider(userId)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return NubarEmptyState(
            icon: Icons.perm_media_outlined,
            title: l10n.noMedia,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _MediaTile(post: post);
          },
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  final PostModel post;

  const _MediaTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final urls = post.mediaUrls;
    final previewUrl =
        post.thumbnailUrl ??
        (urls != null && urls.isNotEmpty ? urls.first : null);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: previewUrl == null
                  ? Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: previewUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
            ),
          ),
          PositionedDirectional(
            end: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                post.type.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
