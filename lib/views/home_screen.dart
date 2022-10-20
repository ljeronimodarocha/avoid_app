import 'package:avoid_app/providers/auth_provider.dart';
import 'package:avoid_app/providers/video_provider.dart';
import 'package:avoid_app/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _showErrorDialog(String msg) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Ocorreu um erro'),
                content: Text(msg),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (!Provider.of<AuthProvider>(context, listen: false)
                            .isAuth) {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoute.AUTH);
                        }
                      },
                      child: const Text('Fechar'))
                ],
              ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Provider.of<VideoProvider>(context, listen: false).loadFilmes(),
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
                  onRefresh: () =>
                      Provider.of<VideoProvider>(context, listen: false)
                          .loadFilmes()
                          .catchError(
                            (error) => _showErrorDialog(error!.message),
                          ),
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: videos.videoCount,
                      itemBuilder: (ctx, index) {
                        return Card(
                          margin: const EdgeInsets.all(25),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pushNamed(
                                AppRoute.VIDEO,
                                arguments: Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .token),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(videos.items[index].nome),
                                  Text(videos.items[index].uri),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                );
              },
            );
          }
        },
      ),
    );
  }
}
