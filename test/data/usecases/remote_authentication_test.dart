import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/data/usecases/usecases.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HttpClientSpy extends Mock implements HttpClient {}

late HttpClient httpClient;
late String url;
late RemoteAuthentication sut;
late AuthenticationParams params;
String guid = faker.guid.guid();

Map mockValidData() => {
      'headers': {'set-cookie': guid},
      'body': {'teste': 'teste'}
    };

When mockRequest() => when(() => httpClient.request(
    url: url,
    method: 'post',
    body: {'username': params.userName, 'password': params.secret}));

void mockHttpData(Map data) {
  mockRequest().thenAnswer((_) async => data);
}

void mockHttpError(HttpError error) {
  mockRequest().thenThrow(error);
}

void main() {
  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    params = AuthenticationParams(
        userName: faker.internet.userName(), secret: faker.internet.password());
    mockHttpData(mockValidData());
    //sut = system under test
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });
  test('Shoud call HttpClient with correct values', () async {
    await sut.auth(params);

    verify(
      () => httpClient.request(
        url: url,
        method: 'post',
        body: {'username': params.userName, 'password': params.secret},
      ),
    );
  });

  test('Shoud throw UnexpectedError if HttpCLiente returns 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Shoud throw UnexpectedError if HttpCLiente returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Shoud throw UnexpectedError if HttpCLiente returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Shoud throw InvalidCredentialsError if if HttpCLiente returns 401',
      () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Shoud return an Account if if if HttpCLiente returns 200', () async {
    final validaData = mockValidData();

    final account = await sut.auth(params);

    expect(account.token, validaData['headers']['set-cookie']);
  });

  test(
      'Shoud throw UnexpectedError if if if HttpCLiente returns 200 with invalid data',
      () async {
    mockHttpData({'invalid_key': 'invalid_value'});
    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
