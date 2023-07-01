import 'dart:convert';

import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/infra/http/http.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class ClienteSpy extends Mock implements Client {}

When mockClientRequest({Map? map}) => when(() => client.post(
      Uri.parse(url),
      body: map != null ? jsonEncode(map) : null,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json'
      },
    ));

void mockHttpData(
    {Map? dataREquest, required Map returnData, required int httpStatus}) {
  mockClientRequest(map: dataREquest)
      .thenAnswer((_) async => Response(jsonEncode(returnData), httpStatus));
}

late String url;
late ClienteSpy client;
late HttpAdapter sut;

void main() {
  setUp(() {
    url = faker.internet.httpUrl();
    client = ClienteSpy();
    mockHttpData(returnData: {}, httpStatus: 200);
    sut = HttpAdapter(client);
  });
  group('shared', () {
    test('Should throw ServerError if invalid method is provived', () async {
      final future = sut.request(url: url, method: 'invalid_method');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('post', () {
    test('Should call post with correct values', () {
      mockClientRequest(map: {'any_field': 'any_value'})
          .thenAnswer((_) async => Response('', 200));

      sut.request(url: url, method: 'post', body: {'any_field': 'any_value'});
      verify(() => client.post(
            Uri.parse(url),
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json'
            },
            body: jsonEncode({'any_field': 'any_value'}),
          )).called(1);
    });

    test('Should call post without body', () {
      sut.request(url: url, method: 'post');
      verify(() => client.post(
            Uri.parse(url),
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json'
            },
          )).called(1);
    });

    test('Should return data if post returns 200', () async {
      mockHttpData(
          dataREquest: {'any_field': 'any_value'},
          returnData: {'any_field': 'any_value'},
          httpStatus: 200);
      final responde = await sut
          .request(url: url, method: 'post', body: {'any_field': 'any_value'});

      expect(responde, {'any_field': 'any_value'});
    });

    test('Should return nnull if post returns 200 with no data', () async {
      final responde = await sut.request(url: url, method: 'post');

      expect(responde, {});
    });

    test('Should return null if post returns 204', () async {
      mockHttpData(returnData: {}, httpStatus: 204);
      final responde = await sut.request(url: url, method: 'post');

      expect(responde, null);
    });

    test('Should return null if post returns 204 with data', () async {
      mockHttpData(returnData: {}, httpStatus: 204);

      final responde = await sut.request(url: url, method: 'post');

      expect(responde, null);
    });

    test('Should return BadRequestError if post returns 400', () async {
      mockHttpData(returnData: {}, httpStatus: 400);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequestError if post returns 400 with data',
        () async {
      mockHttpData(dataREquest: {}, returnData: {}, httpStatus: 400);

      final future = sut.request(url: url, method: 'post', body: {});

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if post returns 401', () async {
      mockHttpData(returnData: {}, httpStatus: 401);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if post returns 403', () async {
      mockHttpData(returnData: {}, httpStatus: 403);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return NotFoundError if post returns 404', () async {
      mockHttpData(returnData: {}, httpStatus: 404);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if post returns 500', () async {
      mockHttpData(returnData: {}, httpStatus: 500);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if post throws', () async {
      mockClientRequest().thenThrow("");

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('get', () {});
}
