import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/constants/supabase_constants.dart';
import 'package:nubar/shared/services/supabase_service.dart';

Future<void> showReportDialog(
  BuildContext context,
  WidgetRef ref, {
  String? postId,
  String? commentId,
}) async {
  final l10n = AppLocalizations.of(context)!;

  String? selectedReason;
  final detailsController = TextEditingController();

  final reasons = [
    {'key': 'spam', 'label': l10n.spam},
    {'key': 'harassment', 'label': l10n.harassment},
    {'key': 'hate_speech', 'label': l10n.hateSpeech},
    {'key': 'misinformation', 'label': l10n.misinformation},
    {'key': 'other', 'label': l10n.other},
  ];

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.reportReason),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) {
                      final isSelected = selectedReason == reason['key'];
                      return ChoiceChip(
                        label: Text(reason['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedReason =
                                selected ? reason['key'] : null;
                          });
                        },
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.reportDetails,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: selectedReason == null
                    ? null
                    : () async {
                        try {
                          final currentUser = SupabaseService.currentUser;
                          if (currentUser == null) return;

                          final profile = await SupabaseService.from(
                                  SupabaseConstants.usersTable)
                              .select('id')
                              .eq('auth_id', currentUser.id)
                              .single();

                          final reason = detailsController.text.isNotEmpty
                              ? '$selectedReason: ${detailsController.text}'
                              : selectedReason!;

                          await SupabaseService.from(
                                  SupabaseConstants.reportsTable)
                              .insert({
                            'reporter_id': profile['id'],
                            if (postId != null) 'post_id': postId,
                            if (commentId != null)
                              'comment_id': commentId,
                            'reason': reason,
                          });

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.reportSubmitted)),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.error)),
                            );
                          }
                        }
                      },
                child: Text(l10n.send),
              ),
            ],
          );
        },
      );
    },
  );

  detailsController.dispose();
}
