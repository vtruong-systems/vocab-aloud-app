import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/sponsor_links.dart';
import '../constants/sponsor_video.dart';

class SponsorVideoPlayer extends StatefulWidget {
  const SponsorVideoPlayer({super.key});

  @override
  State<SponsorVideoPlayer> createState() => _SponsorVideoPlayerState();
}

class _SponsorVideoPlayerState extends State<SponsorVideoPlayer> {
  VideoPlayerController? _controller;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final controller = VideoPlayerController.asset(sponsorVideoAsset);
    _controller = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      await controller.setVolume(0.5);
      controller.addListener(_onVideoUpdate);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.black87,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Sponsor video missing. Run scripts/prepare_assets.sh before building.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: const ColoredBox(
          color: Colors.black87,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final isPlaying = controller.value.isPlaying;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => launchStaticGamersStore(context),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          GestureDetector(
            onTap: _togglePlayback,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
