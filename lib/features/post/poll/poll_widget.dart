import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/features/post/poll/poll_model.dart';
import 'package:nubar/features/post/poll/poll_provider.dart';
import 'package:nubar/core/utils/date_utils.dart' as app_date;

class PollWidget extends ConsumerWidget {
  final String postId;

  const PollWidget({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollAsync = ref.watch(pollProvider(postId));

    return pollAsync.when(
      data: (poll) {
        if (poll == null) return const SizedBox.shrink();
        return _PollContent(poll: poll);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PollContent extends ConsumerWidget {
  final PollModel poll;

  const _PollContent({required this.poll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showResults = poll.hasVoted || poll.isExpired;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          ...poll.options.map((option) {
            if (showResults) {
              return _PollResultBar(
                option: option,
                totalVotes: poll.totalVotes,
                isSelected: poll.userVote == option.key,
              );
            }
            return _PollOptionButton(
              option: option,
              onTap: () {
                ref.read(pollActionsProvider).vote(
                      pollId: poll.id,
                      postId: poll.postId,
                      optionKey: option.key,
                    );
              },
            );
          }),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${poll.totalVotes} votes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              if (poll.endsAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  poll.isExpired
                      ? 'Ended'
                      : 'Ends ${app_date.NubarDateUtils.timeAgo(poll.endsAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PollOptionButton extends StatelessWidget {
  final PollOption option;
  final VoidCallback onTap;

  const _PollOptionButton({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          alignment: AlignmentDirectional.centerStart,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(option.text),
      ),
    );
  }
}

class _PollResultBar extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool isSelected;

  const _PollResultBar({
    required this.option,
    required this.totalVotes,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = option.percentage(totalVotes);
    final percentText = '${(percentage * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // Background bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: FractionallySizedBox(
                widthFactor: percentage,
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          // Text overlay
          SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  if (isSelected) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                  Text(
                    percentText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
