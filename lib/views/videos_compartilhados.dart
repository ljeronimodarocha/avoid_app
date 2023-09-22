import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/video_provider.dart';
import '../widges/item_video.dart';

class VideosCompartilhadosComigo extends StatelessWidget {
  const VideosCompartilhadosComigo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Provider.of<VideoProvider>(context, listen: false)
            .loadFilmesCompartilhados(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text("Ocorreu um erro!"),
            );
          } else {
            return Consumer<VideoProvider>(
              builder: (ctx, videos, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<VideoProvider>(context, listen: false)
                        .loadFilmesCompartilhados();
                  },
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.builder(
                        itemCount: videos.videoSharedCount,
                        itemBuilder: (ctx, index) =>
                            /*  ItemVideo(videos.sharedItens[index], false), */
                            Text('data')),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
