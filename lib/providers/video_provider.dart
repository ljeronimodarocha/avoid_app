import 'dart:convert';

import 'package:avoid_app/model/video_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    }).timeout(const Duration(seconds: 5));
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
}
