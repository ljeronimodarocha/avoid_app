import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/domain/usecases/save_movie.dart';

import '../../../domain/helpers/helpers.dart';

class RemoteSaveMovie implements SaveMovie {
  HttpClient httpClient;
  String url;

  RemoteSaveMovie(this.httpClient, this.url);
  @override
  Future<void> save(MovieEntity params) async {
    final body = RemoteMovieParams.fromDomain(params).toJson;
    try {
      final httpResponse =
          await httpClient.request(url: url, method: 'POST', body: body);
      if (httpResponse == null || httpResponse['statusCode'] != 200) {
        throw DomainError.unexpected;
      }
    } on HttpError catch (error) {
      throw error == HttpError.unauthorized
          ? DomainError.invalidCredentials
          : DomainError.unexpected;
    }
  }
}

class RemoteMovieParams {
  final String nome;
  final String categoria;

  RemoteMovieParams({required this.nome, required this.categoria});

  Map get toJson => {'nome': nome, 'categoria': categoria};

  factory RemoteMovieParams.fromDomain(MovieEntity params) =>
      RemoteMovieParams(nome: params.nome, categoria: params.categoria);
}
