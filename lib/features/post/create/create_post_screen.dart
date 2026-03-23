import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/feed/providers/feed_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/core/utils/current_user_profile.dart';
import 'package:nubar/features/post/create/create_post_provider.dart';
import 'package:nubar/features/profile/providers/profile_content_provider.dart';
import 'package:nubar/shared/widgets/nubar_quill_toolbar.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? communityId;
  final String? editPostId;
  final String? initialContent;
  final List<dynamic>? initialRichDelta;

  /// When set, creates a Twitter-style post reply (see [reply_to_post_id]).
  final String? replyToPostId;
  final String? replyToUsername;

  const CreatePostScreen({
    super.key,
    this.communityId,
    this.editPostId,
    this.initialContent,
    this.initialRichDelta,
    this.replyToPostId,
    this.replyToUsername,
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  late final QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  File? _selectedPdf;
  String? _pdfFileName;

  // Poll
  bool _isPollMode = false;
  final List<TextEditingController> _pollControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _pollHours = 24;

  // Media bar
  bool _showMediaBar = false;
  late final AnimationController _mediaBarAnim;
  bool get _isEditMode => widget.editPostId != null;

  ProviderSubscription<AsyncValue<void>>? _createPostSub;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    if (_isEditMode) {
      final delta = widget.initialRichDelta;
      if (delta != null && delta.isNotEmpty) {
        try {
          _quillController.document = Document.fromJson(
            List<Map<String, dynamic>>.from(delta),
          );
        } catch (_) {
          final initialText = widget.initialContent?.trim() ?? '';
          if (initialText.isNotEmpty) {
            _quillController.document = Document.fromJson([
              {'insert': '$initialText\n'},
            ]);
          }
        }
      } else {
        final initialText = widget.initialContent?.trim() ?? '';
        if (initialText.isNotEmpty) {
          _quillController.document = Document.fromJson([
            {'insert': '$initialText\n'},
          ]);
        }
      }
    } else if (widget.replyToPostId == null) {
      _loadDraft();
    }
    _quillController.document.changes.listen((_) => _saveDraft());
    _mediaBarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createPostSub ??= ref.listenManual<AsyncValue<void>>(createPostProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          if (previous is! AsyncLoading) return;
          if (!_hasContent) return;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            HapticFeedback.mediumImpact();
            ref.invalidate(feedProvider);
            if (!_isEditMode) {
              await _clearDraft();
              try {
                final uid = await CurrentUserProfile.getOrCreateId();
                ref.invalidate(profilePostsProvider(uid));
                ref.invalidate(profileRepliesProvider(uid));
                ref.invalidate(profilePhotosProvider(uid));
                ref.invalidate(profileMediaProvider(uid));
                ref.invalidate(profileLikedPostsProvider(uid));
                ref.invalidate(profileSavedPostsProvider(uid));
              } catch (_) {}
            }
            if (_isEditMode && widget.editPostId != null) {
              ref.invalidate(postDetailProvider(widget.editPostId!));
            }
            if (!mounted) return;
            Navigator.of(context).maybePop();
          });
        },
        error: (error, _) {
          if (previous is! AsyncLoading) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        },
      );
    });
  }

  @override
  void dispose() {
    _createPostSub?.close();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _mediaBarAnim.dispose();
    for (final c in _pollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('nubar_post_draft');
    if (draft != null && mounted) {
      try {
        final doc = Document.fromJson(jsonDecode(draft));
        setState(() => _quillController.document = doc);
      } catch (_) {}
    }
  }

  Future<void> _saveDraft() async {
    if (_isEditMode || widget.replyToPostId != null) return;
    final prefs = await SharedPreferences.getInstance();
    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
    await prefs.setString('nubar_post_draft', deltaJson);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nubar_post_draft');
  }

  bool get _hasContent {
    final plainText = _quillController.document.toPlainText().trim();
    return plainText.isNotEmpty ||
        _selectedImages.isNotEmpty ||
        _selectedVideo != null ||
        _selectedPdf != null ||
        _isPollMode;
  }

  // â”€â”€ Media â”€â”€

  Future<void> _pickImages() async {
    final imgs = await _imagePicker.pickMultiImage();
    if (imgs.isNotEmpty) {
      setState(() {
        _selectedVideo = null;
        _selectedPdf = null;
        _isPollMode = false;
        for (final img in imgs) {
          if (_selectedImages.length < AppConstants.maxImagesPerPost) {
            _selectedImages.add(File(img.path));
          }
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final p = await _imagePicker.pickImage(source: ImageSource.camera);
    if (p != null && _selectedImages.length < AppConstants.maxImagesPerPost) {
      setState(() {
        _selectedImages.add(File(p.path));
        _selectedVideo = null;
        _selectedPdf = null;
        _isPollMode = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final v = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (v != null) {
      final videoFile = File(v.path);
      final maxBytes = AppConstants.maxVideoSizeMB * 1024 * 1024;
      if (await videoFile.length() > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Max ${AppConstants.maxVideoSizeMB}MB')),
          );
        }
        return;
      }
      setState(() {
        _selectedVideo = videoFile;
        _selectedImages.clear();
        _selectedPdf = null;
        _isPollMode = false;
      });
    }
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (r != null && r.files.isNotEmpty) {
      final picked = r.files.first;
      if (picked.size > AppConstants.maxPdfSizeMB * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Max ${AppConstants.maxPdfSizeMB}MB')),
          );
        }
        return;
      }
      setState(() {
        _selectedPdf = File(picked.path!);
        _pdfFileName = picked.name;
        _selectedImages.clear();
        _selectedVideo = null;
        _isPollMode = false;
      });
    }
  }

  void _togglePoll() {
    setState(() {
      _isPollMode = !_isPollMode;
      if (_isPollMode) {
        _selectedImages.clear();
        _selectedVideo = null;
        _selectedPdf = null;
      }
    });
  }

  void _toggleMediaBar() {
    _showMediaBar = !_showMediaBar;
    if (_showMediaBar) {
      _mediaBarAnim.forward();
    } else {
      _mediaBarAnim.reverse();
    }
    setState(() {});
  }

  void _handlePost() {
    if (!_hasContent) return;
    final plainText = _quillController.document.toPlainText().trim();
    final richDeltaJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );
    final postValidation = Validators.validatePostContent(plainText);
    if (postValidation != null &&
        _selectedImages.isEmpty &&
        _selectedVideo == null &&
        _selectedPdf == null &&
        !_isPollMode) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(postValidation)));
      return;
    }
    final pollOptions = _pollControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    if (_isPollMode && pollOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.addOption} (2+)'),
        ),
      );
      return;
    }

    if (_isEditMode) {
      ref
          .read(createPostProvider.notifier)
          .updatePostContent(
            postId: widget.editPostId!,
            content: plainText,
            richDeltaJson: richDeltaJson,
          );
      return;
    }

    ref
        .read(createPostProvider.notifier)
        .createPost(
          content: plainText,
          replyToPostId: widget.replyToPostId,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          video: _selectedVideo,
          pdf: _selectedPdf,
          pdfFileName: _pdfFileName,
          pollQuestion: plainText,
          pollOptions: _isPollMode ? pollOptions : null,
          pollHours: _isPollMode ? _pollHours : null,
          richDeltaJson: richDeltaJson,
          communityId: widget.communityId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final createState = ref.watch(createPostProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // â”€â”€ Top bar â”€â”€
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        if (_hasContent) {
                          _showDiscardDialog(context, l10n);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    if (widget.replyToPostId != null) ...[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Text(
                            l10n.replyingToUser(
                              (widget.replyToUsername ?? '').isEmpty
                                  ? '…'
                                  : widget.replyToUsername!,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    AnimatedOpacity(
                      opacity: _hasContent ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 200),
                      child: FilledButton(
                        onPressed: createState.isLoading || !_hasContent
                            ? null
                            : _handlePost,
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
                        child: createState.isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text(
                                l10n.post,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // â”€â”€ Rich text editor (fills remaining space) â”€â”€
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuillEditor(
                    controller: _quillController,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: NubarQuillConfigBuilder.buildConfig(
                      context: context,
                      placeholder: l10n.writePost,
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 80),
                      autoFocus: true,
                    ),
                  ),
                ),
              ),

              // â”€â”€ Poll / Media attachments â”€â”€
              if (_isPollMode ||
                  _selectedImages.isNotEmpty ||
                  _selectedVideo != null ||
                  _selectedPdf != null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_isPollMode)
                          _PollEditor(
                            controllers: _pollControllers,
                            hours: _pollHours,
                            onHoursChanged: (h) =>
                                setState(() => _pollHours = h),
                            onAdd: () {
                              if (_pollControllers.length < 4) {
                                setState(
                                  () => _pollControllers.add(
                                    TextEditingController(),
                                  ),
                                );
                              }
                            },
                            onRemove: (i) {
                              if (_pollControllers.length > 2) {
                                setState(() {
                                  _pollControllers[i].dispose();
                                  _pollControllers.removeAt(i);
                                });
                              }
                            },
                            onClose: _togglePoll,
                          ),
                        if (_selectedImages.isNotEmpty) _buildImageRow(),
                        if (_selectedVideo != null)
                          _AttachmentChip(
                            icon: Icons.videocam_rounded,
                            label: _selectedVideo!.path.split('/').last,
                            color: cs.tertiary,
                            onRemove: () =>
                                setState(() => _selectedVideo = null),
                          ),
                        if (_selectedPdf != null)
                          _AttachmentChip(
                            icon: Icons.picture_as_pdf_rounded,
                            label: _pdfFileName ?? 'PDF',
                            color: cs.error,
                            onRemove: () => setState(() {
                              _selectedPdf = null;
                              _pdfFileName = null;
                            }),
                          ),
                      ],
                    ),
                  ),
                ),

              // â”€â”€ Expandable media row â”€â”€
              SizeTransition(
                sizeFactor: _mediaBarAnim,
                axisAlignment: -1,
                child: _isEditMode
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          border: Border(
                            top: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _MediaBtn(
                              Icons.photo_library_outlined,
                              l10n.addImage,
                              cs.primary,
                              _pickImages,
                            ),
                            _MediaBtn(
                              Icons.camera_alt_outlined,
                              l10n.camera,
                              cs.primary,
                              _takePhoto,
                            ),
                            _MediaBtn(
                              Icons.videocam_outlined,
                              l10n.addVideo,
                              cs.tertiary,
                              _pickVideo,
                            ),
                            _MediaBtn(
                              Icons.picture_as_pdf_outlined,
                              l10n.addPdf,
                              cs.error,
                              _pickPdf,
                            ),
                            _MediaBtn(
                              Icons.poll_outlined,
                              l10n.poll,
                              cs.secondary,
                              _togglePoll,
                              active: _isPollMode,
                            ),
                          ],
                        ),
                      ),
              ),

              // â”€â”€ Bottom formatting toolbar â”€â”€
              NubarQuillToolbar(
                controller: _quillController,
                focusNode: _focusNode,
                trailingAction: _isEditMode
                    ? null
                    : NubarQuillToolIcon(
                        icon: _showMediaBar
                            ? Icons.close_rounded
                            : Icons.add_circle_outline_rounded,
                        onTap: _toggleMediaBar,
                        active: _showMediaBar,
                        baseColor: cs.secondary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageRow() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImages[i],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImages.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: cs.scrim.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscardDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discard),
        content: Text(l10n.discardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              _clearDraft();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// â”€â”€ Media button for expandable bar â”€â”€
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _MediaBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  const _MediaBtn(
    this.icon,
    this.label,
    this.color,
    this.onTap, {
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.1)
                : color.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// â”€â”€ Attachment chip â”€â”€
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _AttachmentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _AttachmentChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// â”€â”€ Poll editor â”€â”€
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _PollEditor extends StatelessWidget {
  final List<TextEditingController> controllers;
  final int hours;
  final ValueChanged<int> onHoursChanged;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final VoidCallback onClose;

  const _PollEditor({
    required this.controllers,
    required this.hours,
    required this.onHoursChanged,
    required this.onAdd,
    required this.onRemove,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                l10n.poll,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close_rounded, size: 18, color: cs.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            controllers.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(
                        hintText: '${l10n.option} ${i + 1}',
                        isDense: true,
                        filled: true,
                        fillColor: cs.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (controllers.length > 2) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onRemove(i),
                      child: Icon(
                        Icons.remove_circle_outline,
                        size: 18,
                        color: cs.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (controllers.length < 4)
            GestureDetector(
              onTap: onAdd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.addOption,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: cs.outline),
              const SizedBox(width: 6),
              Text(
                l10n.pollDuration,
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 6, label: Text('6h')),
                        ButtonSegment(value: 24, label: Text('1d')),
                        ButtonSegment(value: 72, label: Text('3d')),
                        ButtonSegment(value: 168, label: Text('7d')),
                      ],
                      selected: {hours},
                      onSelectionChanged: (s) => onHoursChanged(s.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
