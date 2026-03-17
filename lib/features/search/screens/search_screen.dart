import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/feed/widgets/post_card.dart';
import 'package:nubar/features/profile/screens/profile_screen.dart';
import 'package:nubar/features/search/providers/search_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.search,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value.trim();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.posts),
            Tab(text: l10n.profile),
          ],
        ),
      ),
      body: query.isEmpty
          ? _buildTrending(context, ref)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPostResults(context, ref),
                _buildUserResults(context, ref),
              ],
            ),
    );
  }

  Widget _buildTrending(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trending = ref.watch(trendingHashtagsProvider);

    return trending.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => Center(child: Text(l10n.error)),
      data: (hashtags) {
        if (hashtags.isEmpty) return Center(child: Text(l10n.noResults));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.trending,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...hashtags.map(
              (tag) => ListTile(
                leading: const Icon(Icons.tag),
                title: Text('#${tag['name']}'),
                trailing: Text(
                  '${tag['post_count']} ${l10n.posts}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  _searchController.text = '#${tag['name']}';
                  ref.read(searchQueryProvider.notifier).state =
                      '#${tag['name']}';
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostResults(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(searchPostsProvider);

    return postsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => Center(child: Text(l10n.error)),
      data: (posts) {
        if (posts.isEmpty) return Center(child: Text(l10n.noResults));

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }

  Widget _buildUserResults(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(searchUsersProvider);

    return usersAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => Center(child: Text(l10n.error)),
      data: (users) {
        if (users.isEmpty) return Center(child: Text(l10n.noResults));

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: NubarAvatar(
                imageUrl: user.avatarUrl,
                radius: 22,
                fallbackText: user.fullName,
              ),
              title: Text(user.fullName),
              subtitle: Text('@${user.username}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: user.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
