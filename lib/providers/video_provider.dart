import 'dart:convert';

import 'package:avoid_app/model/video_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../exceptions/firebase_exception.dart';

class VideoProvider with ChangeNotifier {
  String? _token;
  List<VideoModel>? _items = [];

  VideoProvider([this._token, this._items]);

  final String _url = "http://192.168.15.9:3000/filme";

  List<VideoModel> get items => [...?_items];

  Future<void> loadFilmes() async {
    List<VideoModel> loadeditems = [];
    final response = await http.get(Uri.parse(_url), headers: {
      'Authorization': _token!
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode == 403) {
      throw Exception("Efetue o login novamente!");
    }
    List data = jsonDecode(response.body);
    loadeditems.clear();
    if (data != null) {
      data.forEach((element) {
        loadeditems.add(VideoModel(element['id'].toString(), element['nome'],
            element['categoriaFilmes']));
      });
    }
    _items = loadeditems.reversed.toList();
    return Future.value();
  }

  int get videoCount {
    return _items!.length;
  }

  Future<void> addVideo(
      String nome, String categoria, PlatformFile file) async {
    final response = await http
        .post(Uri.parse(_url),
            headers: <String, String>{
              'Authorization': _token!,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'nome': nome,
              'categoriaFilmes': categoria,
            }))
        .timeout(
          const Duration(seconds: 5),
        );
    final respondeBody = jsonDecode(response.body);
    if (respondeBody["error"] != null) {
      throw FireBaseException(respondeBody["error"]['message']);
    } else if (respondeBody["id"] == null) {
      throw const FireBaseException("Erro ao adicionar o Vídeo");
    } else {
      final id = respondeBody["id"];

      var request =
          http.MultipartRequest("POST", Uri.parse('${_url}/${id}/file'));
      request.headers.addAll(
        <String, String>{
          'Authorization': _token!,
        },
      );
      request.files.add(await http.MultipartFile.fromPath("file", file.path!));
      final response2 = await request.send();
      if (response2.statusCode != 200) {
        await http.delete(
          Uri.parse('${_url}/${id}'),
          headers: <String, String>{
            'Authorization': _token!,
            'Content-Type': 'application/json',
          },
        );
      }
    }
    return Future.value();
  }
}
