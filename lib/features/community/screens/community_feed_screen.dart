import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nubar/features/community/providers/community_provider.dart';
import 'package:nubar/features/community/screens/community_settings_screen.dart';
import 'package:nubar/features/post/create/create_post_screen.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';

class CommunityFeedScreen extends ConsumerWidget {
  final String communityId;

  const CommunityFeedScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final communityAsync = ref.watch(communityDetailProvider(communityId));
    final isMemberAsync = ref.watch(isCommunityMemberProvider(communityId));

    return communityAsync.when(
      data: (community) {
        final isMember = isMemberAsync.valueOrNull ?? false;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Banner and header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(community.name),
                  background: community.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: community.bannerUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                ),
                actions: [
                  if (isMember)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunitySettingsScreen(
                              communityId: communityId,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              // Community info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and stats row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: community.avatarUrl != null
                                ? CachedNetworkImageProvider(
                                    community.avatarUrl!,
                                  )
                                : null,
                            child: community.avatarUrl == null
                                ? Text(
                                    community.name[0].toUpperCase(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.memberCount(community.memberCount),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  l10n.postCount(community.postCount),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // Join/Leave button
                          if (isMember)
                            NubarButton(
                              text: l10n.leaveCommunity,
                              isOutlined: true,
                              onPressed: () async {
                                await ref
                                    .read(communityActionsProvider)
                                    .leaveCommunity(communityId);
                              },
                            )
                          else
                            NubarButton(
                              text: l10n.joinCommunity,
                              onPressed: () async {
                                await ref
                                    .read(communityActionsProvider)
                                    .joinCommunity(communityId);
                              },
                            ),
                        ],
                      ),

                      if (community.description != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          community.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],

                      if (community.isPrivate) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outlined,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Private',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Divider(height: 1)),

              // Community posts placeholder
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.noPosts,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: isMember
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreatePostScreen(communityId: communityId),
                      ),
                    );
                  },
                  child: const Icon(Icons.edit),
                )
              : null,
        );
      },
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.error)),
      ),
    );
  }
}
