import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/post/studio/providers/studio_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class StudioPdfHubScreen extends ConsumerStatefulWidget {
  const StudioPdfHubScreen({super.key});

  @override
  ConsumerState<StudioPdfHubScreen> createState() => _StudioPdfHubScreenState();
}

class _StudioPdfHubScreenState extends ConsumerState<StudioPdfHubScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  File? _coverImage;
  File? _pdfFile;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkContent);
    _authorController.addListener(_checkContent);
    _summaryController.addListener(_checkContent);
  }

  void _checkContent() {
    final titleEmpty = _titleController.text.trim().isEmpty;
    final authorEmpty = _authorController.text.trim().isEmpty;
    final summaryEmpty = _summaryController.text.trim().isEmpty;

    final hasContent =
        !titleEmpty &&
        !authorEmpty &&
        !summaryEmpty &&
        _coverImage != null &&
        _pdfFile != null;
    if (_hasContent != hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
      _checkContent();
    }
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
      _checkContent();
    }
  }

  void _handlePost() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final pages = _pagesController.text.trim();
    final summary = _summaryController.text.trim();

    await ref
        .read(studioProvider.notifier)
        .createPdfHub(
          title: title,
          author: author,
          pageCount: pages,
          summary: summary,
          coverImage: _coverImage!,
          pdfFile: _pdfFile!,
        );

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
            title: Text(l10n.bookHub),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Layout for Cover Image & PDF metadata side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Picker
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        width: 120,
                        height: 170,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: _coverImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.pdfCover,
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Title, Author, Pages Fields
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.pdfTitle,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _authorController,
                            style: tt.bodyLarge,
                            decoration: InputDecoration(
                              labelText: l10n.pdfAuthor,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _pagesController,
                            style: tt.bodyLarge,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.pdfPagesOptional,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Attach PDF Button
                InkWell(
                  onTap: _pickPdfFile,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _pdfFile != null
                          ? cs.tertiary.withValues(alpha: 0.1)
                          : cs.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _pdfFile != null
                            ? cs.tertiary
                            : cs.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _pdfFile != null ? cs.tertiary : cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _pdfFile != null
                                ? Icons.check_rounded
                                : Icons.picture_as_pdf_rounded,
                            color: cs.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pdfFile != null
                                    ? l10n.pdfDocAdded
                                    : l10n.pdfSelectDoc,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _pdfFile != null
                                      ? cs.tertiary
                                      : cs.onSurface,
                                ),
                              ),
                              if (_pdfFile != null)
                                Text(
                                  _pdfFile!.path.split('/').last,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Summary Box
                Text(
                  l10n.pdfSummaryInfo,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _summaryController,
                    style: tt.bodyLarge,
                    decoration: InputDecoration(
                      hintText: l10n.pdfSummaryHint,
                      hintStyle: tt.bodyLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 8,
                    minLines: 4,
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
