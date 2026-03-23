import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/post/detail/post_detail_screen.dart';
import 'package:nubar/features/profile/providers/profile_content_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_empty_state.dart';
import 'package:nubar/shared/widgets/nubar_error_widget.dart';

class ProfilePhotosTab extends ConsumerWidget {
  final String userId;

  const ProfilePhotosTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final photosAsync = ref.watch(profilePhotosProvider(userId));

    return photosAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => NubarErrorWidget(
        onRetry: () => ref.invalidate(profilePhotosProvider(userId)),
      ),
      data: (posts) {
        final photoPosts = posts.where((post) {
          final urls = post.mediaUrls;
          return urls != null && urls.isNotEmpty;
        }).toList();

        if (photoPosts.isEmpty) {
          return NubarEmptyState(
            icon: Icons.photo_outlined,
            title: l10n.noPhotos,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: photoPosts.length,
          itemBuilder: (context, index) {
            final post = photoPosts[index];
            final imageUrl = post.mediaUrls!.first;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
