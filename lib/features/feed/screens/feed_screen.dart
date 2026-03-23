import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:nubar/features/feed/widgets/post_card.dart';
import 'package:nubar/features/feed/widgets/story_bar.dart';
import 'package:nubar/features/notifications/screens/notifications_screen.dart';
import 'package:nubar/features/post/create/create_post_screen.dart';
import 'package:nubar/features/post/studio/screens/studio_article_screen.dart';
import 'package:nubar/features/post/studio/screens/studio_pdf_hub_screen.dart';
import 'package:nubar/features/post/studio/screens/studio_quiz_screen.dart';
import 'package:nubar/features/post/studio/screens/studio_thread_screen.dart';
import 'package:nubar/features/post/studio/screens/studio_voice_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PagingController<int, PostModel> _pagingController = PagingController(
    firstPageKey: 0,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final posts = await ref.read(feedProvider(pageKey).future);
      final isLastPage = posts.length < AppConstants.defaultPageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(posts);
      } else {
        _pagingController.appendPage(posts, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _showCreateMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.contentStudio,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildMenuButton(
                    ctx,
                    Icons.edit_note_rounded,
                    l10n.quickPost,
                    cs.primary,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    ctx,
                    Icons.article_rounded,
                    l10n.article,
                    cs.secondary,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudioArticleScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    ctx,
                    Icons.quiz_rounded,
                    l10n.quiz,
                    cs.tertiary,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudioQuizScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    ctx,
                    Icons.menu_book_rounded,
                    l10n.bookHub,
                    cs.error,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudioPdfHubScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    ctx,
                    Icons.format_list_numbered_rtl_rounded,
                    l10n.thread,
                    cs.primaryContainer,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudioThreadScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    ctx,
                    Icons.mic_rounded,
                    l10n.voiceNote,
                    cs.onSurfaceVariant,
                    () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudioVoiceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Story bar
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: StoryBar(),
              ),
            ),

            // Divider
            const SliverToBoxAdapter(child: Divider(height: 1)),

            // Posts
            PagedSliverList<int, PostModel>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PostModel>(
                itemBuilder: (context, post, index) => PostCard(post: post),
                firstPageErrorIndicatorBuilder: (context) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.error),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _pagingController.refresh(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMenu(context, l10n),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
