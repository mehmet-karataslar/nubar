import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/core/utils/current_user_profile.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/post/poll/poll_model.dart';
import 'package:nubar/shared/services/supabase_service.dart';

// Get poll for a post
final pollProvider = FutureProvider.family<PollModel?, String>((
  ref,
  postId,
) async {
  final response = await SupabaseService.from(
    SupabaseConstants.pollsTable,
  ).select().eq('post_id', postId).maybeSingle();

  if (response == null) return null;

  // Check if current user has voted
  String? userVote;
  final currentUser = await ref.read(currentUserProvider.future);
  if (currentUser != null) {
    final appUserId = await CurrentUserProfile.getOrCreateId();
    final voteResponse =
        await SupabaseService.from(SupabaseConstants.pollVotesTable)
            .select('option_key')
            .eq('poll_id', response['id'])
            .eq('user_id', appUserId)
            .maybeSingle();
    userVote = voteResponse?['option_key'] as String?;
  }

  return PollModel.fromJson(response, userVote: userVote);
});

// Poll actions
final pollActionsProvider = Provider<PollActions>((ref) => PollActions(ref));

class PollActions {
  final Ref _ref;
  PollActions(this._ref);

  Future<void> vote({
    required String pollId,
    required String postId,
    required String optionKey,
  }) async {
    final currentUser = await _ref.read(currentUserProvider.future);
    if (currentUser == null) throw Exception('Not authenticated');
    final appUserId = await CurrentUserProfile.getOrCreateId();

    // Insert vote
    await SupabaseService.from(SupabaseConstants.pollVotesTable).insert({
      'poll_id': pollId,
      'user_id': appUserId,
      'option_key': optionKey,
    });

    // Update poll options count via RPC or re-fetch
    final poll = await SupabaseService.from(
      SupabaseConstants.pollsTable,
    ).select().eq('id', pollId).single();

    final options = Map<String, dynamic>.from(poll['options'] as Map);
    if (options.containsKey(optionKey)) {
      final option = Map<String, dynamic>.from(options[optionKey] as Map);
      option['count'] = (option['count'] as int? ?? 0) + 1;
      options[optionKey] = option;
    }

    await SupabaseService.from(
      SupabaseConstants.pollsTable,
    ).update({'options': options}).eq('id', pollId);

    _ref.invalidate(pollProvider(postId));
  }

  Future<void> createPoll({
    required String postId,
    required String question,
    required List<String> optionTexts,
    DateTime? endsAt,
  }) async {
    final options = <String, dynamic>{};
    for (int i = 0; i < optionTexts.length; i++) {
      options['option_$i'] = {'text': optionTexts[i], 'count': 0};
    }

    await SupabaseService.from(SupabaseConstants.pollsTable).insert({
      'post_id': postId,
      'question': question,
      'options': options,
      'ends_at': endsAt?.toIso8601String(),
    });
  }
}
