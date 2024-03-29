import 'dart:ui';

import 'package:avoid_app/providers/video_provider.dart';
import 'package:avoid_app/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widges/drawer_app.dart';
import '../widges/item_video.dart';

class HomeScreen extends StatefulWidget {
  final bool habilitarMenuOpcoes;

  const HomeScreen(this.habilitarMenuOpcoes, {super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: Provider.of<VideoProvider>(context, listen: false)
                  .loadFilmes(),
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
                        onRefresh: () {
                          Provider.of<VideoProvider>(context, listen: false)
                              .loadFilmes();
                          setState(() {});
                          return Future.value();
                        },
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            itemCount: videos.videoCount,
                            itemBuilder: (ctx, index) =>
                                ItemVideo(videos.items[index], true),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed(AppRoute.ADD_VIDEO),
      ),
      drawer: DrawerApp(),
    );
  }
}
