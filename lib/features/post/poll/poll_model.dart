class PollModel {
  final String id;
  final String postId;
  final String question;
  final List<PollOption> options;
  final DateTime? endsAt;
  final DateTime createdAt;
  final int totalVotes;
  final String? userVote;

  const PollModel({
    required this.id,
    required this.postId,
    required this.question,
    required this.options,
    this.endsAt,
    required this.createdAt,
    this.totalVotes = 0,
    this.userVote,
  });

  bool get isExpired =>
      endsAt != null && DateTime.now().isAfter(endsAt!);

  bool get hasVoted => userVote != null;

  factory PollModel.fromJson(Map<String, dynamic> json, {String? userVote}) {
    final optionsJson = json['options'] as Map<String, dynamic>;
    final options = optionsJson.entries
        .map((e) => PollOption(
              key: e.key,
              text: e.value['text'] as String,
              voteCount: e.value['count'] as int? ?? 0,
            ))
        .toList();

    final totalVotes = options.fold<int>(0, (sum, o) => sum + o.voteCount);

    return PollModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      question: json['question'] as String,
      options: options,
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalVotes: totalVotes,
      userVote: userVote,
    );
  }
}

class PollOption {
  final String key;
  final String text;
  final int voteCount;

  const PollOption({
    required this.key,
    required this.text,
    this.voteCount = 0,
  });

  double percentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return voteCount / totalVotes;
  }
}
