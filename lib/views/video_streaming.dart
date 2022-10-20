import 'package:avoid_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoStraming extends StatefulWidget {
  @override
  State<VideoStraming> createState() => _VideoStramingState();
}

class _VideoStramingState extends State<VideoStraming> {
  VideoPlayerController? _controller;
  String? dateTimeString;

  @override
  void initState() {
    super.initState();
    String token =
        Provider.of<AuthProvider>(context, listen: false).token.toString();

    _controller = VideoPlayerController.network(
        'http://192.168.15.9:3000/filme/video/33',
        httpHeaders: <String, String>{'Authorization': token})
      ..initialize().then((_) {
        setState(() {});
      });

    _controller!.play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: _controller!.value.isInitialized
          ? Container(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    _ControlsOverlay(controller: _controller!),
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                    ),
                  ],
                ),
              ),
            )
          : AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                width: double.maxFinite,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 10),
          reverseDuration: const Duration(milliseconds: 10),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
            setState(() {});
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.red),
              child: PopupMenuButton<double>(
                initialValue: widget.controller.value.playbackSpeed,
                tooltip: 'Playback speed',
                onSelected: (double speed) {
                  widget.controller.setPlaybackSpeed(speed);
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<double>>[
                    for (final double speed in _examplePlaybackRates)
                      PopupMenuItem<double>(
                        value: speed,
                        child: Text('${speed}x'),
                      )
                  ];
                },
                child: Text('${widget.controller.value.playbackSpeed}x'),
              ),
            ),
          ),
        )
      ],
    );
  }
}
