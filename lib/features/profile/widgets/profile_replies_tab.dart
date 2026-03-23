import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/feed/widgets/post_card.dart';
import 'package:nubar/features/profile/providers/profile_content_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_empty_state.dart';
import 'package:nubar/shared/widgets/nubar_error_widget.dart';

class ProfileRepliesTab extends ConsumerWidget {
  final String userId;

  const ProfileRepliesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repliesAsync = ref.watch(profileRepliesProvider(userId));

    return repliesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => NubarErrorWidget(
        onRetry: () => ref.invalidate(profileRepliesProvider(userId)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return NubarEmptyState(
            icon: Icons.reply_all_rounded,
            title: l10n.noReplies,
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
