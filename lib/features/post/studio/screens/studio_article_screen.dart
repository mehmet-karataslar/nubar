import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:nubar/features/post/studio/providers/studio_provider.dart';
import 'package:nubar/shared/widgets/nubar_quill_toolbar.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class StudioArticleScreen extends ConsumerStatefulWidget {
  const StudioArticleScreen({super.key});

  @override
  ConsumerState<StudioArticleScreen> createState() =>
      _StudioArticleScreenState();
}

class _StudioArticleScreenState extends ConsumerState<StudioArticleScreen> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  File? _coverImage;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _quillController.addListener(_checkContent);
    _titleController.addListener(_checkContent);
  }

  void _checkContent() {
    final titleEmpty = _titleController.text.trim().isEmpty;
    final bodyEmpty = _quillController.document.isEmpty();
    final hasContent = !titleEmpty && (!bodyEmpty || _coverImage != null);
    if (_hasContent != hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  void _handlePost() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final contentDelta = _quillController.document.toDelta().toJson();

    await ref
        .read(studioProvider.notifier)
        .createArticle(
          title: title,
          subtitle: subtitle,
          contentDelta: jsonEncode(contentDelta),
          coverImage: _coverImage,
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
            title: Text(l10n.article),
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
                      backgroundColor: cs.onSurface,
                      foregroundColor: cs.surface,
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
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: _pickCoverImage,
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            image: _coverImage != null
                                ? DecorationImage(
                                    image: FileImage(_coverImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _coverImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: 48,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.addCoverImage,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: cs.scrim.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: cs.onPrimary,
                                        size: 18,
                                      ),
                                    ),
                                    onPressed: () =>
                                        setState(() => _coverImage = null),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              style: tt.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.articleTitleHint,
                                hintStyle: tt.headlineLarge?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _subtitleController,
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.articleSubtitleHint,
                                hintStyle: tt.titleMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 8,
                        ),
                        child: Divider(height: 1, color: cs.outlineVariant),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: quill.QuillEditor(
                          controller: _quillController,
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          config: NubarQuillConfigBuilder.buildConfig(
                            context: context,
                            placeholder: l10n.articleBodyHint,
                            padding: const EdgeInsets.only(bottom: 80, top: 10),
                            autoFocus: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NubarQuillToolbar(
                controller: _quillController,
                focusNode: _focusNode,
              ),
            ],
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
