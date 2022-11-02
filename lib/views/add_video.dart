import 'package:avoid_app/providers/video_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddVideo extends StatefulWidget {
  const AddVideo({super.key});

  @override
  State<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  PlatformFile? objFile;

  final GlobalKey<FormState> _form = GlobalKey();

  final Map<String, String> _videoData = {'nome': '', 'categoriaFilmes': ''};

  bool isLoading = false;

  List<String> list = <String>['TERROR', 'COMEDIA', 'SUSPENSE', 'AVENTURA'];

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    if (objFile == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: const Text("Selecione o vídeo desejado"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Fechar'))
                ],
              ));
      return;
    }
    _form.currentState?.save();
    setState(() {
      isLoading = true;
    });
    await Provider.of<VideoProvider>(context, listen: false).addVideo(
        _videoData['nome']!, _videoData['categoriaFilmes']!, objFile!);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_videoData['categoriaFilmes']!.isEmpty) {
      _videoData['categoriaFilmes'] = list[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Vídeo'),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator())
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (value) => _videoData['nome'] = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe um nome válido";
                        }
                        return null;
                      },
                    ),
                    DropdownButton(
                        value: _videoData['categoriaFilmes'],
                        items: list.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _videoData['categoriaFilmes'] = value!;
                          });
                        }),
                    TextButton(
                      child: const Text("Selecionar arquivo"),
                      onPressed: () async {
                        var result = await FilePicker.platform.pickFiles(
                          withReadStream: true,
                          allowMultiple: false,
                          type: FileType.video,
                        );

                        if (result != null) {
                          setState(() {
                            objFile = result.files.single;
                          });
                        }
                      },
                    ),
                    if (objFile != null)
                      Text("Nome do arquivo : ${objFile!.name}"),
                    if (objFile != null)
                      Text("Tamanho do arquivo : ${objFile!.size} bytes"),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Enviar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
