import '../../../domain/entities/entities.dart';
import '../../../domain/helpers/helpers.dart';
import '../../../domain/usecases/usecases.dart';
import '../../http/http.dart';
import '../../models/models.dart';

class RemoteAuthentication implements Authentication {
  final HttpClient httpClient;
  String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  @override
  Future<AccountEntity> auth(AuthenticationParams params) async {
    final body = RemoteAuthenticationParams.fromDomain(params).toJson;
    try {
      final httpResponse =
          await httpClient.request(url: url, method: 'post', body: body);
      if (httpResponse == null) {
        throw DomainError.unexpected;
      } else if (httpResponse['headers'] == null) {
        throw DomainError.unexpected;
      }
      return RemoteAccountModel.fromJson(httpResponse['headers']).toEntity();
    } on HttpError catch (error) {
      throw error == HttpError.unauthorized
          ? DomainError.invalidCredentials
          : DomainError.unexpected;
    }
  }
}

class RemoteAuthenticationParams {
  final String userName;
  final String password;

  RemoteAuthenticationParams({required this.userName, required this.password});

  Map get toJson => {'username': userName, 'password': password};

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams params) =>
      RemoteAuthenticationParams(
          userName: params.userName, password: params.secret);
}
