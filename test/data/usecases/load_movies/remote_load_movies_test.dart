import 'dart:convert';

import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/data/usecases/load_movies/remote_load_movies.dart';
import 'package:avoid_app/domain/entities/account_entity.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientSpy extends Mock implements HttpClient {}

class LoadCurrentAccountSpy extends Mock implements LoadCurrentAccount {}

void main() {
  late HttpClientSpy httpClient;
  late RemoteLoadMovies sut;
  late LoadCurrentAccount loadCurrentAccount;
  String url = '/filme';
  final token = faker.guid.guid();
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

  When mockRequest() => when(() =>
      httpClient.request(url: url, method: 'get', headers: {'Cookie': token}));
  When mockLoadCUrrentAccount() => when(() => loadCurrentAccount.load());

  setUp(() {
    httpClient = HttpClientSpy();
    loadCurrentAccount = LoadCurrentAccountSpy();
    sut = RemoteLoadMovies(httpClient, url, loadCurrentAccount);
    mockRequest().thenAnswer(
        (_) async => {'statusCode': 200, 'body': jsonEncode(listMovie)});
    mockLoadCUrrentAccount().thenAnswer((_) async => AccountEntity(token));
  });

  test('Should call correct url and method', () async {
    await sut.load();
    verify(() => httpClient
        .request(url: url, method: 'get', headers: {'Cookie': token}));
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
