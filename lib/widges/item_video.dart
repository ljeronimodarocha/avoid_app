import 'package:avoid_app/model/video_model.dart';
import 'package:flutter/material.dart';

import '../utils/app_route.dart';

class ItemVideo extends StatelessWidget {
  final VideoModel item;
  const ItemVideo(this.item);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 5),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoute.VIDEO, arguments: item.id),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.nome),
              Text(item.uri),
            ],
          ),
        ),
      ),
    );
  }
}
