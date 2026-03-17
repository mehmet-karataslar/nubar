import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/features/auth/providers/auth_provider.dart';
import 'package:nubar/features/post/create/create_post_provider.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? communityId;

  const CreatePostScreen({super.key, this.communityId});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final _imagePicker = ImagePicker();
  File? _selectedVideo;
  File? _selectedPdf;
  String? _pdfFileName;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        for (final image in images) {
          if (_selectedImages.length < AppConstants.maxImagesPerPost) {
            _selectedImages.add(File(image.path));
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _pickVideo() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _selectedImages.clear();
        _selectedPdf = null;
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdf = File(result.files.first.path!);
        _pdfFileName = result.files.first.name;
        _selectedImages.clear();
        _selectedVideo = null;
      });
    }
  }

  void _handlePost() {
    final content = _contentController.text.trim();
    if (content.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedVideo == null &&
        _selectedPdf == null) return;

    ref.read(createPostProvider.notifier).createPost(
          content: content,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          communityId: widget.communityId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createPostProvider);
    final currentUser = ref.watch(currentUserProvider);

    ref.listen(createPostProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          if (_contentController.text.isNotEmpty ||
              _selectedImages.isNotEmpty) {
            Navigator.pop(context);
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPost),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: createState.isLoading ? null : _handlePost,
              child: createState.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.post),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NubarAvatar(
                        imageUrl: currentUser.valueOrNull?.avatarUrl,
                        radius: 20,
                        fallbackText: currentUser.valueOrNull?.fullName,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          maxLength: AppConstants.maxPostLength,
                          decoration: InputDecoration(
                            hintText: l10n.writePost,
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),

                  // Selected video
                  if (_selectedVideo != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.videocam,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedVideo!.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => _selectedVideo = null),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Selected PDF
                  if (_selectedPdf != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pdfFileName ?? 'PDF',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() {
                              _selectedPdf = null;
                              _pdfFileName = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Selected images
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImages[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
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
                  ],
                ],
              ),
            ),
          ),

          // Bottom toolbar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _selectedImages.length < AppConstants.maxImagesPerPost
                      ? _pickImages
                      : null,
                  tooltip: l10n.addImage,
                ),
                IconButton(
                  icon: Icon(
                    Icons.videocam_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _selectedPdf == null ? _pickVideo : null,
                  tooltip: l10n.addVideo,
                ),
                IconButton(
                  icon: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _selectedVideo == null ? _pickPdf : null,
                  tooltip: l10n.addPdf,
                ),
                const Spacer(),
                Text(
                  '${_contentController.text.length}/${AppConstants.maxPostLength}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
