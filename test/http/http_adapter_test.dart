import 'dart:convert';

import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/infra/http/http.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class ClienteSpy extends Mock implements Client {
  constClientSpy() {
    mockPost(200);
    mockPut(200);
    mockGet(200);
  }

  When mockPostCall() => when(() => this
      .post(any(), body: any(named: 'body'), headers: any(named: 'headers')));
  void mockPost(int statusCode, {String body = '{"any_key":"any_value"}'}) =>
      mockPostCall().thenAnswer((_) async => Response(body, statusCode));
  void mockPostError() => when(() => mockPostCall().thenThrow(Exception()));

  When mockPutCall() => when(() => this
      .put(any(), body: any(named: 'body'), headers: any(named: 'headers')));
  void mockPut(int statusCode, {String body = '{"any_key":"any_value"}'}) =>
      mockPutCall().thenAnswer((_) async => Response(body, statusCode));
  void mockPutError() => when(() => mockPutCall().thenThrow(Exception()));

  When mockGetCall() =>
      when(() => this.get(any(), headers: any(named: 'headers')));
  void mockGet(int statusCode, {String body = '{"any_key":"any_value"}'}) =>
      mockGetCall().thenAnswer((_) async => Response(body, statusCode));
  void mockGetError() => when(() => mockGetCall().thenThrow(Exception()));
}

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
  setUpAll(() {
    url = faker.internet.httpUrl();
    registerFallbackValue(Uri.parse(url));
  });
  setUp(() {
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

  group('get', () {
    test('Should call get with correct values', () async {
      client.mockGet(200);

      await sut.request(url: url, method: 'get');
      verify(() => client.get(Uri.parse(url), headers: {
            'content-type': 'application/json',
            'accept': 'application/json'
          }));

      await sut.request(
          url: url, method: 'get', headers: {'any_header': 'any_value'});
      verify(() => client.get(Uri.parse(url), headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
            'any_header': 'any_value'
          }));
    });

    test('Should return data if get returns 200', () async {
      client.mockGet(200);

      final response = await sut.request(url: url, method: 'get');

      expect(response, {'any_key': 'any_value'});
    });

    test('Should return null if get returns 200 with no data', () async {
      client.mockGet(200, body: '');

      final response = await sut.request(url: url, method: 'get');

      expect(response, null);
    });

    test('Should return null if get returns 204', () async {
      client.mockGet(204, body: '');

      final response = await sut.request(url: url, method: 'get');

      expect(response, null);
    });

    test('Should return null if get returns 204 with data', () async {
      client.mockGet(204);

      final response = await sut.request(url: url, method: 'get');

      expect(response, null);
    });

    test('Should return BadRequestError if get returns 400', () async {
      client.mockGet(400, body: '');

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequestError if get returns 400', () async {
      client.mockGet(400);

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if get returns 401', () async {
      client.mockGet(401);

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if get returns 403', () async {
      client.mockGet(403);

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return NotFoundError if get returns 404', () async {
      client.mockGet(404);

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if get returns 500', () async {
      client.mockGet(500);

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if get throws', () async {
      client.mockGetError();

      final future = sut.request(url: url, method: 'get');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('put', () {
    test('Should call put with correct values', () async {
      client.mockPut(200);
      await sut
          .request(url: url, method: 'put', body: {'any_key': 'any_value'});
      verify(() => client.put(Uri.parse(url),
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json'
          },
          body: '{"any_key":"any_value"}'));

      await sut.request(
          url: url,
          method: 'put',
          body: {'any_key': 'any_value'},
          headers: {'any_header': 'any_value'});
      verify(() => client.put(Uri.parse(url),
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
            'any_header': 'any_value'
          },
          body: '{"any_key":"any_value"}'));
    });

    test('Should call put without body', () async {
      client.mockPut(200);
      await sut.request(url: url, method: 'put');

      verify(() => client.put(any(), headers: any(named: 'headers')));
    });

    test('Should return data if put returns 200', () async {
      client.mockPut(200);
      final response = await sut.request(url: url, method: 'put');

      expect(response, {'any_key': 'any_value'});
    });

    test('Should return null if put returns 200 with no data', () async {
      client.mockPut(200, body: '');

      final response = await sut.request(url: url, method: 'put');

      expect(response, null);
    });

    test('Should return null if put returns 204', () async {
      client.mockPut(204, body: '');

      final response = await sut.request(url: url, method: 'put');

      expect(response, null);
    });

    test('Should return null if put returns 204 with data', () async {
      client.mockPut(204);

      final response = await sut.request(url: url, method: 'put');

      expect(response, null);
    });

    test('Should return BadRequestError if put returns 400', () async {
      client.mockPut(400, body: '');

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequestError if put returns 400', () async {
      client.mockPut(400);

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if put returns 401', () async {
      client.mockPut(401);

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if put returns 403', () async {
      client.mockPut(403);

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return NotFoundError if put returns 404', () async {
      client.mockPut(404);

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if put returns 500', () async {
      client.mockPut(500);

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if put throws', () async {
      client.mockPutError();

      final future = sut.request(url: url, method: 'put');

      expect(future, throwsA(HttpError.serverError));
    });
  });
}
