import 'dart:ui';

import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/ui/pages/home/home_presenter.dart';
import 'package:avoid_app/utils/app_route.dart';
import 'package:flutter/material.dart';

import '../../../widges/drawer_app.dart';
import 'components/item_video.dart';

class HomeScreen extends StatefulWidget {
  final bool? habilitarMenuOpcoes = false;
  final HomePresenter presenter;

  const HomeScreen(habilitarMenuOpcoes, this.presenter);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  List<MovieEntity> items = [];

  @override
  Widget build(BuildContext context) {
    widget.presenter.load();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: widget.presenter.movies,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text("Ocorreu um erro!"),
            );
          } else if (snapshot.data != null || snapshot.data!.isNotEmpty) {
            items = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () => widget.presenter.load(),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) =>
                      ItemVideo(snapshot.data![index], true),
                ),
              ),
            );
          } else {
            return const Center(
              child: Text("Ocorreu um erro!"),
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
