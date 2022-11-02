import 'package:avoid_app/providers/auth_provider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoStraming extends StatefulWidget {
  @override
  State<VideoStraming> createState() => _VideoStramingState();
}

class _VideoStramingState extends State<VideoStraming> {
  FlickManager? flickManaFger;
  String? dateTimeString;
  String? token;

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token.toString();

    //_controller!.play();
  }

  @override
  void dispose() {
    super.dispose();
    flickManaFger?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idFilme = ModalRoute.of(context)?.settings.arguments;
    flickManaFger = FlickManager(
        videoPlayerController: VideoPlayerController.network(
            'http://192.168.15.9:3000/filme/video/${idFilme}',
            httpHeaders: <String, String>{'Authorization': token!}));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlickVideoPlayer(
            flickManager: flickManaFger!,
            preferredDeviceOrientationFullscreen: const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitDown,
            ],
            flickVideoWithControlsFullscreen: const FlickVideoWithControls(),
          ),
          _ControlsOverlay(
              controller:
                  flickManaFger!.flickVideoManager!.videoPlayerController!),
        ],
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
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: PopupMenuButton<double>(
          initialValue: widget.controller.value.playbackSpeed,
          tooltip: 'Playback speed',
          onSelected: (double speed) {
            widget.controller.setPlaybackSpeed(speed);
            setState(() {});
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
          child: const Icon(
            Icons.settings,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
