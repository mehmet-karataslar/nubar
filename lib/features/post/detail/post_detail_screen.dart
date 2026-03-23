import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/date_utils.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/feed/widgets/post_actions.dart';
import 'package:nubar/features/post/create/create_post_screen.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    ref.read(feedActionsProvider.notifier).addComment(widget.postId, content);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return postAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.post)),
        body: const LoadingIndicator(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.post)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (post) {
        if (post == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.post)),
            body: Center(child: Text(l10n.noResults)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.post),
            actions: [
              IconButton(
                icon: const Icon(Icons.reply_rounded),
                tooltip: l10n.reply,
                onPressed: () {
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
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author
                            Row(
                              children: [
                                NubarAvatar(
                                  imageUrl: post.authorAvatarUrl,
                                  radius: 24,
                                  fallbackText: post.authorFullName,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.authorFullName ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '@${post.authorUsername ?? ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
                            ),
                            const SizedBox(height: 12),
                            if (post.replyToPostId != null) ...[
                              _ReplyParentBanner(
                                parentPostId: post.replyToPostId!,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Content
                            if (post.content != null)
                              _PostDetailRichContent(post: post),
                            const SizedBox(height: 12),

                            // Date
                            Text(
                              NubarDateUtils.formatDateTime(post.createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                            const SizedBox(height: 12),

                            // Stats
                            Row(
                              children: [
                                Text(
                                  l10n.followerCount(post.likeCount),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  l10n.postCount(post.commentCount),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PostActions(post: post),
                      ),

                      const Divider(),

                      // Comments
                      commentsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: LoadingIndicator(),
                        ),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.error),
                        ),
                        data: (comments) {
                          if (comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  l10n.noResults,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return ListTile(
                                leading: NubarAvatar(
                                  imageUrl: comment.authorAvatarUrl,
                                  radius: 18,
                                  fallbackText: comment.authorFullName,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      comment.authorFullName ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      NubarDateUtils.timeAgo(comment.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(comment.content),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: NubarTextField(
                        controller: _commentController,
                        hint: l10n.writeComment,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReplyParentBanner extends ConsumerWidget {
  final String parentPostId;

  const _ReplyParentBanner({required this.parentPostId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(postDetailProvider(parentPostId));
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return parentAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => const SizedBox.shrink(),
      data: (parent) {
        if (parent == null) return const SizedBox.shrink();
        final handle = parent.authorUsername;
        return Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PostDetailScreen(postId: parent.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.replyingToUser(
                      (handle == null || handle.isEmpty) ? '…' : '@$handle',
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parent.content?.trim().isNotEmpty == true
                        ? parent.content!.trim()
                        : '…',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PostDetailRichContent extends StatelessWidget {
  final PostModel post;

  const _PostDetailRichContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final delta = post.metadata?['rich_delta'];
    if (delta is List) {
      try {
        final doc = Document.fromJson(List<Map<String, dynamic>>.from(delta));
        final controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        return IgnorePointer(
          child: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              expands: false,
              scrollable: false,
              padding: EdgeInsets.zero,
              showCursor: false,
            ),
          ),
        );
      } catch (_) {
        // Fallback to plain text below.
      }
    }

    return Text(
      post.content ?? '',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
