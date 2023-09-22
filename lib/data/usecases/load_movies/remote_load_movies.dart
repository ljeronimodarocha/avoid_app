import 'dart:convert';

import 'package:avoid_app/domain/usecases/usecases.dart';

import '../../../domain/entities/movie_entity.dart';
import '../../../domain/helpers/helpers.dart';
import '../../../domain/usecases/load_movies.dart';
import '../../http/http.dart';

class RemoteLoadMovies implements LoadMovies {
  final HttpClient httpClient;
  final String url;
  final LoadCurrentAccount _loadCurrentAccount;

  RemoteLoadMovies(this.httpClient, this.url, this._loadCurrentAccount);

  @override
  Future<List<MovieEntity>> load() async {
    List<MovieEntity> listMovie = [];
    var account = await _loadCurrentAccount.load();
    try {
      final response = await httpClient
          .request(url: url, method: 'get', headers: {'Cookie': account.token});
      if (response == null || response['body'] == null) {
        throw HttpError.badRequest;
      }
      final body = jsonDecode(response['body']) as List;
      for (var element in body) {
        listMovie.add(MovieEntity(
            element['id'], element['nome'], element['categoriaFilmes']));
      }
    } on HttpError catch (error) {
      throw error == HttpError.unauthorized
          ? DomainError.invalidCredentials
          : DomainError.unexpected;
    }
    return listMovie;
  }
}
