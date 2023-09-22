import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:flutter/material.dart';

import '../utils/app_route.dart';
import 'menu_opcoes.dart';

class ItemVideo extends StatelessWidget {
  final MovieEntity item;
  final bool habilitarMenuOpcoes;
  const ItemVideo(this.item, this.habilitarMenuOpcoes, {super.key});

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
              const Spacer(),
              Text(item.categoria),
              if (habilitarMenuOpcoes) MenuOpcoes(item.id!),
            ],
          ),
        ),
      ),
    );
  }
}
