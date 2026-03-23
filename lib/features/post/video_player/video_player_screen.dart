import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: widget.thumbnailUrl != null
            ? Image.network(widget.thumbnailUrl!, fit: BoxFit.cover)
            : null,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.scrim,
      appBar: AppBar(
        backgroundColor: cs.scrim,
        foregroundColor: cs.onPrimary,
        title: widget.title != null ? Text(widget.title!) : null,
      ),
      body: Center(
        child: _isError
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: cs.onPrimary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Video could not be loaded',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: cs.onPrimary),
                  ),
                ],
              )
            : _chewieController != null
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(color: cs.onPrimary),
      ),
    );
  }
}
