import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/profile/providers/block_provider.dart';
import 'package:nubar/shared/services/supabase_service.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';

/// Model for a blocked user's display info
class BlockedUserInfo {
  final String userId;
  final String username;
  final String fullName;
  final String? avatarUrl;

  const BlockedUserInfo({
    required this.userId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });
}

/// Provider that fetches full profile info for blocked users
final blockedUsersInfoProvider = FutureProvider<List<BlockedUserInfo>>((
  ref,
) async {
  final blockedIds = await ref.watch(blockedUserIdsProvider.future);
  if (blockedIds.isEmpty) return [];

  final response = await SupabaseService.from(SupabaseConstants.usersTable)
      .select('id, username, full_name, avatar_url')
      .inFilter('id', blockedIds.toList());

  return (response as List).map((json) {
    final data = json as Map<String, dynamic>;
    return BlockedUserInfo(
      userId: data['id'] as String,
      username: data['username'] as String? ?? '',
      fullName: data['full_name'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
    );
  }).toList();
});

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final blockedUsersAsync = ref.watch(blockedUsersInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedUsers)),
      body: blockedUsersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(child: Text(l10n.error)),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noBlockedUsers,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: NubarAvatar(
                  imageUrl: user.avatarUrl,
                  radius: 22,
                  fallbackText: user.fullName,
                ),
                title: Text(
                  user.fullName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('@${user.username}'),
                trailing: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.unblock),
                        content: Text(
                          '${user.fullName} ${l10n.unblockConfirm}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(l10n.cancel),
                          ),
                          FilledButton(
                            onPressed: () {
                              ref
                                  .read(blockActionsProvider.notifier)
                                  .unblockUser(user.userId);
                              Navigator.pop(dialogContext);
                              ref.invalidate(blockedUsersInfoProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.userUnblocked)),
                              );
                            },
                            child: Text(l10n.unblock),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(l10n.unblock),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
