// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/post/studio/providers/studio_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class StudioQuizScreen extends ConsumerStatefulWidget {
  const StudioQuizScreen({super.key});

  @override
  ConsumerState<StudioQuizScreen> createState() => _StudioQuizScreenState();
}

class _StudioQuizScreenState extends ConsumerState<StudioQuizScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  int _correctOptionIndex = 0;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_checkContent);
    for (var controller in _optionControllers) {
      controller.addListener(_checkContent);
    }
  }

  void _checkContent() {
    final questionEmpty = _questionController.text.trim().isEmpty;
    final optionsValid = _optionControllers.every(
      (c) => c.text.trim().isNotEmpty,
    );

    final hasContent = !questionEmpty && optionsValid;
    if (_hasContent != hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  void _addOption() {
    if (_optionControllers.length < 5) {
      // max 5 options
      final controller = TextEditingController();
      controller.addListener(_checkContent);
      setState(() {
        _optionControllers.add(controller);
      });
      _checkContent();
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      final controller = _optionControllers[index];
      controller.removeListener(_checkContent);
      controller.dispose();
      setState(() {
        _optionControllers.removeAt(index);
        if (_correctOptionIndex >= index && _correctOptionIndex > 0) {
          _correctOptionIndex--;
        }
      });
      _checkContent();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handlePost() async {
    final question = _questionController.text.trim();
    final explanation = _explanationController.text.trim();
    final options = _optionControllers.map((c) => c.text.trim()).toList();

    // Since our provider only takes title, subtitle and contentDelta right now,
    // we need to adapt StudioProvider.
    // We can store the quiz data encoded into contentDelta or we update the provider.
    // For now, we will store Quiz structure inside contentDelta as JSON to reuse provider.

    final quizData = {
      'type': 'quiz',
      'question': question,
      'options': options,
      'correctIndex': _correctOptionIndex,
      if (explanation.isNotEmpty) 'explanation': explanation,
    };

    await ref
        .read(studioProvider.notifier)
        .createArticle(
          title: 'Quiz: $question',
          contentDelta: jsonEncode(quizData),
          // The backend uses 'article' type but we can override it if we update the provider.
        );

    if (mounted) {
      final error = ref.read(studioProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $error')));
      } else {
        Navigator.pop(context); // close screen on success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final studioState = ref.watch(studioProvider);
    final isLoading = studioState.isLoading;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: Text(l10n.quiz),
            scrolledUnderElevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedOpacity(
                  opacity: _hasContent && !isLoading ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton(
                    onPressed: (_hasContent && !isLoading) ? _handlePost : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.post,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _questionController,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.quizQuestionHint,
                      hintStyle: tt.headlineSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.3),
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 24),

                // Options Header
                Text(
                  l10n.quizOptionsAndAnswer,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Dynamic Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _optionControllers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isCorrect = _correctOptionIndex == index;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Radio to select correct
                        Radio<int>(
                          value: index,
                          groupValue: _correctOptionIndex,
                          activeColor: cs.tertiary,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _correctOptionIndex = val);
                            }
                          },
                        ),
                        // Option TextField
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? cs.tertiary.withValues(alpha: 0.1)
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCorrect
                                    ? cs.tertiary
                                    : cs.tertiary.withValues(alpha: 0),
                                width: 2,
                              ),
                            ),
                            child: TextField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                hintText: '${l10n.quizOptionHint} ${index + 1}',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Remove button
                        if (_optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: cs.error,
                            onPressed: () => _removeOption(index),
                          )
                        else
                          const SizedBox(width: 48), // Spacer to align
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Add Option Button
                if (_optionControllers.length < 5)
                  Center(
                    child: TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addOption),
                    ),
                  ),

                const SizedBox(height: 32),

                // Explanation Input
                Text(
                  l10n.quizExplanationOptional,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.quizExplanationDesc,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _explanationController,
                    style: tt.bodyMedium,
                    decoration: InputDecoration(
                      hintText: l10n.quizExplanationHint,
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: cs.scrim.withValues(alpha: 0.3),
            child: const LoadingIndicator(),
          ),
      ],
    );
  }
}
