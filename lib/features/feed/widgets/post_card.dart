import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/date_utils.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/feed/widgets/post_actions.dart';
import 'package:nubar/features/post/create/create_post_screen.dart';
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
                            final currentUser = sheetRef
                                .watch(currentUserProvider)
                                .valueOrNull;
                            final isOwner = currentUser?.id == post.userId;
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOwner)
                                    ListTile(
                                      leading: const Icon(Icons.edit_outlined),
                                      title: Text(l10n.editPost),
                                      onTap: () async {
                                        Navigator.pop(sheetContext);
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CreatePostScreen(
                                              editPostId: post.id,
                                              initialContent:
                                                  post.content ?? '',
                                              initialRichDelta:
                                                  post.metadata?['rich_delta']
                                                      as List<dynamic>?,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (isOwner)
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
                  child: _ExpandablePostBody(post: post),
                ),

              _PostTypePreview(post: post),

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

/// Collapses very long feed bodies to ~40% of viewport height with expand/collapse.
class _ExpandablePostBody extends StatefulWidget {
  final PostModel post;

  const _ExpandablePostBody({required this.post});

  @override
  State<_ExpandablePostBody> createState() => _ExpandablePostBodyState();
}

class _ExpandablePostBodyState extends State<_ExpandablePostBody> {
  bool _expanded = false;
  QuillController? _readOnlyController;

  PostModel get post => widget.post;

  static bool _isLongPost(PostModel p) {
    final text = p.content?.trim() ?? '';
    if (text.length >= 240) return true;
    if (text.split(RegExp(r'\n+')).where((s) => s.isNotEmpty).length > 6) {
      return true;
    }
    final delta = p.metadata?['rich_delta'];
    if (delta is List && delta.length > 14) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _initQuillIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _ExpandablePostBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != post.id ||
        oldWidget.post.content != post.content ||
        oldWidget.post.metadata?['rich_delta'] != post.metadata?['rich_delta']) {
      _disposeQuill();
      _initQuillIfNeeded();
      _expanded = false;
    }
  }

  void _initQuillIfNeeded() {
    final delta = post.metadata?['rich_delta'];
    if (delta is! List) return;
    try {
      final doc = Document.fromJson(List<Map<String, dynamic>>.from(delta));
      _readOnlyController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } catch (_) {
      _readOnlyController = null;
    }
  }

  void _disposeQuill() {
    _readOnlyController?.dispose();
    _readOnlyController = null;
  }

  @override
  void dispose() {
    _disposeQuill();
    super.dispose();
  }

  Widget _buildEditorOrPlain(BuildContext context) {
    if (_readOnlyController != null) {
      return IgnorePointer(
        child: QuillEditor.basic(
          controller: _readOnlyController!,
          config: QuillEditorConfig(
            expands: false,
            scrollable: false,
            padding: EdgeInsets.zero,
            showCursor: false,
          ),
        ),
      );
    }
    return Text(
      post.content ?? '',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final body = _buildEditorOrPlain(context);

    if (!_isLongPost(post)) {
      return body;
    }

    final maxCollapsed = MediaQuery.sizeOf(context).height * 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? body
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxCollapsed),
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: body,
                        ),
                        PositionedDirectional(
                          start: 0,
                          end: 0,
                          bottom: 0,
                          height: 40,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: AlignmentDirectional.topCenter,
                                  end: AlignmentDirectional.bottomCenter,
                                  colors: [
                                    colorScheme.surface.withValues(alpha: 0),
                                    colorScheme.surface.withValues(alpha: 0.95),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: _expanded
                ? l10n.postShowLessContent
                : l10n.postShowFullContent,
            icon: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.primary,
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
        ),
      ],
    );
  }
}

class _PostTypePreview extends StatelessWidget {
  final PostModel post;

  const _PostTypePreview({required this.post});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final metadata = post.metadata ?? const <String, dynamic>{};
    String? title;
    IconData icon = Icons.article_outlined;

    switch (post.type) {
      case 'article':
        title = metadata['article_title'] as String?;
        icon = Icons.article_rounded;
        break;
      case 'thread':
        title = l10n.thread;
        icon = Icons.format_list_numbered_rounded;
        break;
      case 'quiz':
        title = metadata['quiz_question'] as String?;
        icon = Icons.quiz_rounded;
        break;
      case 'voice':
        title = metadata['voice_title'] as String?;
        icon = Icons.mic_rounded;
        break;
      case 'pdf':
        title = metadata['book_title'] as String?;
        icon = Icons.picture_as_pdf_rounded;
        break;
      case 'video':
        title = l10n.addVideo;
        icon = Icons.videocam_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title?.isNotEmpty == true ? title! : post.type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
