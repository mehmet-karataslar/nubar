import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/post/studio/providers/studio_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class StudioThreadScreen extends ConsumerStatefulWidget {
  const StudioThreadScreen({super.key});

  @override
  ConsumerState<StudioThreadScreen> createState() => _StudioThreadScreenState();
}

class _StudioThreadScreenState extends ConsumerState<StudioThreadScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controllers.first.addListener(_checkContent);
  }

  void _checkContent() {
    // thread needs at least 1 non-empty post
    final hasContent = _controllers.any((c) => c.text.trim().isNotEmpty);
    if (_hasContent != hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  void _addThreadPart() {
    if (_controllers.length < 10) {
      // Max 10 parts
      final controller = TextEditingController();
      controller.addListener(_checkContent);
      setState(() {
        _controllers.add(controller);
      });
      _checkContent();
    }
  }

  void _removeThreadPart(int index) {
    if (_controllers.length > 1) {
      final controller = _controllers[index];
      controller.removeListener(_checkContent);
      controller.dispose();
      setState(() {
        _controllers.removeAt(index);
      });
      _checkContent();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handlePost() async {
    final l10n = AppLocalizations.of(context)!;
    final texts = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (texts.isEmpty) return;

    await ref.read(studioProvider.notifier).createThread(threadTexts: texts);

    if (mounted) {
      final error = ref.read(studioProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $error')));
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
            title: Text(l10n.thread),
            scrolledUnderElevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
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
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount:
                _controllers.length + 1, // +1 for the add button at bottom
            itemBuilder: (context, index) {
              if (index == _controllers.length) {
                // Add button
                return Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 48,
                    top: 16,
                    bottom: 40,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _controllers.length < 10
                          ? _addThreadPart
                          : null,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.threadAdd),
                    ),
                  ),
                );
              }

              final isLast = index == _controllers.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thread Line Timeline
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.primaryContainer,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isLast
                                  ? cs.outlineVariant.withValues(alpha: 0)
                                  : cs.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TextField card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _controllers[index],
                                style: tt.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: index == 0
                                      ? l10n.threadFirstHint
                                      : l10n.threadNextHint,
                                  hintStyle: tt.bodyLarge?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.newline,
                              ),
                              if (index > 0)
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    color: cs.error,
                                    onPressed: () => _removeThreadPart(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
