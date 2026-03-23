import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/post/studio/providers/studio_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';

class StudioVoiceScreen extends ConsumerStatefulWidget {
  const StudioVoiceScreen({super.key});

  @override
  ConsumerState<StudioVoiceScreen> createState() => _StudioVoiceScreenState();
}

class _StudioVoiceScreenState extends ConsumerState<StudioVoiceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _bgImage;
  File? _audioFile;
  bool _hasContent = false;
  bool _isMockRecording = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkContent);
    _descController.addListener(_checkContent);
  }

  void _checkContent() {
    final titleEmpty = _titleController.text.trim().isEmpty;
    final descEmpty = _descController.text.trim().isEmpty;

    final hasContent = !titleEmpty && !descEmpty && _audioFile != null;
    if (_hasContent != hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickBgImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bgImage = File(pickedFile.path);
      });
      _checkContent();
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
      _checkContent();
    }
  }

  void _toggleMockRecording() {
    // This is just a UI flare for the MVP. Since we don't have record package yet.
    setState(() {
      _isMockRecording = !_isMockRecording;
    });
    if (!_isMockRecording && _audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ses kaydedildi (MVP Simülasyonu). Cihazdan bir dosya seçmeniz gerekiyor.',
          ),
        ),
      );
    }
  }

  void _handlePost() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    await ref
        .read(studioProvider.notifier)
        .createVoiceNote(
          title: title,
          description: desc,
          backgroundImage: _bgImage,
          audioFile: _audioFile!,
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(l10n.voiceNote, style: TextStyle(color: cs.onPrimary)),
            backgroundColor: cs.surface.withValues(alpha: 0),
            elevation: 0,
            iconTheme: IconThemeData(color: cs.onPrimary),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedOpacity(
                  opacity: _hasContent && !isLoading ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton(
                    onPressed: (_hasContent && !isLoading) ? _handlePost : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.surface,
                      foregroundColor: cs.onSurface,
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
          body: Stack(
            children: [
              // Background Image or Gradient
              Positioned.fill(
                child: _bgImage != null
                    ? Image.file(_bgImage!, fit: BoxFit.cover)
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primaryContainer.withValues(alpha: 0.85),
                              cs.scrim,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              // Dark Tint
              Positioned.fill(
                child: Container(color: cs.scrim.withValues(alpha: 0.6)),
              ),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Recording Status / Audio Selected Status
                      if (_audioFile != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.tertiary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cs.tertiary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: cs.tertiary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.voiceAdded,
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: -0.2, end: 0)
                      else if (_isMockRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cs.error),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: cs.error,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scaleXY(end: 1.5)
                                  .fadeOut(),
                              const SizedBox(width: 8),
                              Text(
                                l10n.voiceRecording,
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          l10n.voicePrompt,
                          style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),

                      const SizedBox(height: 60),

                      // Giant Record Button
                      GestureDetector(
                        onTap: () {
                          if (_audioFile != null) {
                            // play dummy
                          } else {
                            _toggleMockRecording();
                          }
                        },
                        child:
                            Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isMockRecording
                                        ? cs.error.withValues(alpha: 0.2)
                                        : cs.onPrimary.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: _isMockRecording
                                          ? cs.error
                                          : cs.onPrimary.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isMockRecording
                                            ? cs.error
                                            : cs.onPrimary,
                                      ),
                                      child: Icon(
                                        _audioFile != null
                                            ? Icons.play_arrow_rounded
                                            : (_isMockRecording
                                                  ? Icons.stop_rounded
                                                  : Icons.mic_rounded),
                                        size: 40,
                                        color: _isMockRecording
                                            ? cs.onPrimary
                                            : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .animate(target: _isMockRecording ? 1 : 0)
                                .scaleXY(end: 1.2)
                                .tint(color: cs.error.withValues(alpha: 0.3)),
                      ),

                      const SizedBox(height: 24),

                      // Upload File Button
                      TextButton.icon(
                        onPressed: _pickAudioFile,
                        icon: Icon(
                          Icons.upload_file_rounded,
                          color: cs.primary,
                        ),
                        label: Text(
                          l10n.voiceUploadFromDevice,
                          style: TextStyle(color: cs.primary),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Title Field
                      TextField(
                        controller: _titleController,
                        style: tt.headlineMedium?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: l10n.voiceTitleHint,
                          hintStyle: tt.headlineMedium?.copyWith(
                            color: cs.onPrimary.withValues(alpha: 0.38),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.onPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _descController,
                          style: tt.bodyLarge?.copyWith(color: cs.onPrimary),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: l10n.voiceDescHint,
                            hintStyle: tt.bodyLarge?.copyWith(
                              color: cs.onPrimary.withValues(alpha: 0.54),
                            ),
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Change Background Button
                      OutlinedButton.icon(
                        onPressed: _pickBgImage,
                        icon: Icon(Icons.image_rounded, color: cs.onPrimary),
                        label: Text(
                          l10n.voiceBgImage,
                          style: TextStyle(color: cs.onPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: cs.onPrimary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
