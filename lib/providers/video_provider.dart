import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/entities/video_entity.dart';
import '../exceptions/firebase_exception.dart';
import '../utils/Constant.dart';

class VideoProvider with ChangeNotifier {
  final String? _token;
  List<VideoModel>? _items = [];
  List<VideoModel>? _sharedItems = [];
  List<String>? _usuariosFilmeCompartilhados;

  VideoProvider([this._token, this._items]);

  final String _url = '${Constant.urlDefaultApi}filme';

  List<VideoModel> get items => [...?_items];
  List<VideoModel> get sharedItens => [...?_sharedItems];
  List<String> get usuariosFilmeCompartilhados =>
      [...?_usuariosFilmeCompartilhados];

  Future<void> compartilharFilme(int idFilme, List<String> emails) async {
    final response = await http
        .post(Uri.parse('$_url/share'),
            headers: <String, String>{
              'Cookie': _token!,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'idFilme': idFilme,
              'emails': emails,
            }))
        .timeout(
          const Duration(seconds: 5),
        );

    if (response.statusCode != 204) {
      final respondeBody = jsonDecode(response.body);

      if (respondeBody["title"] != null &&
          respondeBody["title"] == "Unauthorized") {
        throw Exception(respondeBody["details"]);
      } else {
        throw Exception(respondeBody["message"]);
      }
    }

    return Future.value();
  }

  Future<void> loadFilmesCompartilhados() async {
    List<VideoModel> sharedItens = [];
    final response = await http.get(Uri.parse('$_url/share'), headers: {
      'Cookie': _token!,
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode == 403) {
      throw Exception("Efetue o login novamente!");
    }
    List data = jsonDecode(response.body);
    sharedItens.clear();
    for (var element in data) {
      sharedItens.add(VideoModel(
          element['id'], element['nome'], element['categoriaFilmes']));
    }
    _sharedItems = sharedItens.reversed.toList();
    notifyListeners();
    return Future.value();
  }

  Future<void> loadFilmes() async {
    List<VideoModel> loadeditems = [];
    final response = await http.get(Uri.parse(_url), headers: {
      'Cookie': _token!,
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode == 403) {
      throw Exception("Efetue o login novamente!");
    }
    List data = jsonDecode(response.body);
    loadeditems.clear();
    for (var element in data) {
      loadeditems.add(VideoModel(
          element['id'], element['nome'], element['categoriaFilmes']));
    }
    _items = loadeditems.reversed.toList();
    notifyListeners();
    return Future.value();
  }

  int get videoCount {
    return _items!.length;
  }

  int get videoSharedCount {
    return _sharedItems!.length;
  }

  Future<void> addVideo(
      String nome, String categoria, PlatformFile file) async {
    final response = await http
        .post(Uri.parse(_url),
            headers: <String, String>{
              'Cookie': _token!,
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
          'Cookie': _token!,
        },
      );
      request.files.add(await http.MultipartFile.fromPath("file", file.path!));
      final responseEnviarArquivo = await request.send();
      if (responseEnviarArquivo.statusCode != 200) {
        await http.delete(
          Uri.parse('${_url}/${id}'),
          headers: <String, String>{
            'Cookie': _token!,
            'Content-Type': 'application/json',
          },
        );
      }
    }
    notifyListeners();
    return Future.value();
  }

  Future<void> listarUsuariosQueFilmeFoiCompartilhado(int id) async {
    final response = await http.get(Uri.parse('$_url/share/$id'), headers: {
      'Cookie': _token!,
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode == 403) {
      throw Exception("Acesso não permitido");
    }
    List<String> data = List<String>.from(jsonDecode(response.body)['emails']);
    _usuariosFilmeCompartilhados = data;
    notifyListeners();
    return Future.value();
  }

  Future<void> excluirFilme(int id) async {
    final response = await http.delete(Uri.parse('$_url/$id'), headers: {
      'Cookie': _token!,
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode != 204) {
      //throw Exception("Acesso não permitido");
    }
    loadFilmes();
    return Future.value();
  }
}
