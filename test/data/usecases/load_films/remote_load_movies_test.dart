import 'dart:convert';

import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/load_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientSpy extends Mock implements HttpClient {}

class RemoveLoadMovies implements load_movies {
  final HttpClient httpClient;
  String url;

  RemoveLoadMovies(this.httpClient, this.url);

  @override
  Future<List<MovieEntity>> load() async {
    List<MovieEntity> listMovie = [];
    try {
      final response = await httpClient.request(url: url, method: 'GET');
      if (response == null ||
          response['statusCode'] != 200 ||
          response['body'] == null) {
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

void main() {
  late HttpClientSpy httpClient;
  late RemoveLoadMovies sut;
  String url = '/filme';
  List<Map> listMovie = [
    {
      'id': 1,
      'nome': 'teste',
      'categoriaFilmes': 'teste',
    },
    {
      'id': 2,
      'nome': 'teste2',
      'categoriaFilmes': 'teste2',
    }
  ];

  When mockRequest() =>
      when(() => httpClient.request(url: '/filme', method: 'GET'));

  setUp(() {
    httpClient = HttpClientSpy();
    sut = RemoveLoadMovies(httpClient, url);
    mockRequest().thenAnswer(
        (_) async => {'statusCode': 200, 'body': jsonEncode(listMovie)});
  });

  test('Should call correct url and method', () {
    sut.load();
    verify(() => httpClient.request(url: url, method: 'GET'));
  });

  test('Should return list Movies', () async {
    final response = await sut.load();
    expect(response.length, 2);
  });

  test('Should return emtpty list Movies', () async {
    mockRequest().thenAnswer((_) async => {'statusCode': 200, 'body': '[]'});
    final response = await sut.load();
    expect(response.length, 0);
  });

  test('Should return 403 when user is not autenticated', () {
    mockRequest().thenThrow(HttpError.unauthorized);
    final future = sut.load();
    expect(future, throwsA(DomainError.invalidCredentials));
  });
}
