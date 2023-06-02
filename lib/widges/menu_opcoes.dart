import 'package:avoid_app/providers/video_provider.dart';
import 'package:avoid_app/size_config.dart';
import 'package:flutter/material.dart';
import 'package:listtextfield/listtextfield.dart';
import 'package:provider/provider.dart';

class MenuOpcoes extends StatelessWidget {
  final int idFilme;

  const MenuOpcoes(this.idFilme);
  @override
  Widget build(BuildContext context) {
    final controller = ListTextEditingController(',');

    void showErrorDialog(String msg) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Ocorreu um erro'),
                content: Text(msg),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Fechar'))
                ],
              ));
    }

    void dialogCompartilhamento(
      ListTextEditingController controller,
    ) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          elevation: 5,
          child: SizedBox(
            width: getProportionateScreenWidth(150),
            height: getProportionateScreenHeight(200),
            child: Padding(
              padding: EdgeInsets.only(
                top: getProportionateScreenWidth(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: getProportionateScreenWidth(2)),
                    child: const Text('Email addresses'),
                  ),
                  ListTextField(
                    controller: controller,
                    itemBuilder: (_, value) {
                      return Chip(
                        label: Text(value),
                        onDeleted: () => controller.removeItem(value),
                      );
                    },
                    itemSpacing: 8,
                    itemLineSpacing: 4,
                    validator: (value) {
                      final emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);
                      if (emailValid) {
                        controller.addItem(value);
                        return null;
                      } else {
                        return 'Enter a valid email address';
                      }
                    },
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide())),
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        try {
                          await Provider.of<VideoProvider>(context,
                                  listen: false)
                              .compartilharFilme(idFilme, controller.items);
                        } catch (error) {
                          showErrorDialog(error.toString());
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: PopupMenuButton(
        tooltip: 'Opções',
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ItensOpcoes>>[
          const PopupMenuItem<ItensOpcoes>(
            value: ItensOpcoes.compartilhar,
            child: Center(
              child: Text('Compartilhar'),
            ),
          ),
          const PopupMenuItem<ItensOpcoes>(
            value: ItensOpcoes.excluir,
            child: Center(
              child: Text('Excluir'),
            ),
          ),
        ],
        onSelected: (value) async {
          if (value == ItensOpcoes.compartilhar) {
            await Provider.of<VideoProvider>(context, listen: false)
                .listarUsuariosQueFilmeFoiCompartilhado(idFilme)
                .then((value) => controller.addAllItems(value));
            dialogCompartilhamento(controller);
          } else if (value == ItensOpcoes.excluir) {
            await Provider.of<VideoProvider>(context, listen: false)
                .excluirFilme(idFilme);
          }
        },
      ),
    );
  }
}

enum ItensOpcoes { compartilhar, excluir }
