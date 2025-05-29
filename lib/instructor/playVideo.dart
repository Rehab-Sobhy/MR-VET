import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo(widget.videoUrl);
    _startControlsTimer();
  }

  Future<void> _initializeVideo(String url) async {
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      })
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startControlsTimer();
    });
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Future<void> _changeQuality(String url) async {
    setState(() => _isInitialized = false);
    await _controller.pause();
    await _controller.dispose();
    _initializeVideo(url);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controlsTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen || !_showControls
          ? null
          : AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.hd, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _QualityMenu(
                        onChange: _changeQuality,
                        currentUrl: widget.videoUrl,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        onDoubleTap: _toggleFullScreen,
        child: Stack(
          children: [
            // Video Player
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.thumbnailUrl != null)
                      Image.network(widget.thumbnailUrl!),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Loading your video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

            // Controls Overlay
            if (_showControls && _isInitialized)
              _VideoControlsOverlay(
                controller: _controller,
                isFullScreen: _isFullScreen,
                onFullScreenTap: _toggleFullScreen,
              ),
          ],
        ),
      ),
    );
  }
}

class _QualityMenu extends StatelessWidget {
  final Function(String) onChange;
  final String currentUrl;

  const _QualityMenu({
    Key? key,
    required this.onChange,
    required this.currentUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Video Quality',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.hd),
            title: const Text('High Quality'),
            onTap: () {
              Navigator.pop(context);
              onChange(currentUrl);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sd),
            title: const Text('Standard Quality'),
            onTap: () {
              Navigator.pop(context);
              onChange(currentUrl.replaceAll('.mp4', '_medium.mp4'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.signal_cellular_alt_1_bar),
            title: const Text('Low Quality'),
            onTap: () {
              Navigator.pop(context);
              onChange(currentUrl.replaceAll('.mp4', '_low.mp4'));
            },
          ),
        ],
      ),
    );
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final VoidCallback onFullScreenTap;

  const _VideoControlsOverlay({
    Key? key,
    required this.controller,
    required this.isFullScreen,
    required this.onFullScreenTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // Play/Pause Button
        Align(
          alignment: Alignment.center,
          child: IconButton(
            iconSize: 60,
            color: Colors.white.withOpacity(0.9),
            icon: Icon(
              controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
            ),
            onPressed: () {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            },
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Progress Bar
                VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white24,
                  ),
                ),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current Time
                    Text(
                      controller.value.position.format(),
                      style: const TextStyle(color: Colors.white),
                    ),

                    // Spacer
                    const Spacer(),

                    // Fullscreen Button
                    IconButton(
                      icon: Icon(
                        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: onFullScreenTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on Duration {
  String format() => toString().substring(2, 7);
}
