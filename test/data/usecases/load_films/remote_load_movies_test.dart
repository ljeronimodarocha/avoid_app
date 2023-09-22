import 'dart:convert';

import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/data/usecases/load_movies/remote_load_movies.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late HttpClientSpy httpClient;
  late RemoteLoadMovies sut;
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
    sut = RemoteLoadMovies(httpClient, url);
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
