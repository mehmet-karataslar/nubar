import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/features/profile/providers/badge_provider.dart';

class BadgeDisplay extends ConsumerWidget {
  final String userId;

  const BadgeDisplay({super.key, required this.userId});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'music_note':
        return Icons.music_note;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'edit_note':
        return Icons.edit_note;
      case 'people':
        return Icons.people;
      case 'trending_up':
        return Icons.trending_up;
      case 'star':
        return Icons.star;
      case 'chat':
        return Icons.chat;
      case 'groups':
        return Icons.groups;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.military_tech;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider(userId));

    return badgesAsync.when(
      data: (badges) {
        if (badges.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: badges.map((badge) {
            return Tooltip(
              message: '${badge.name}: ${badge.description}',
              child: Chip(
                avatar: Icon(
                  _getIconData(badge.icon),
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  badge.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
