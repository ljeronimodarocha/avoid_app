import '../../data/http/http.dart';
import '../../domain/entities/entities.dart';

class RemoteAccountModel {
  final String accessToken;

  RemoteAccountModel(this.accessToken);

  factory RemoteAccountModel.fromJson(Map json) {
    if (!json.containsKey('set-cookie')) {
      throw HttpError.invalidData;
    }
    return RemoteAccountModel(json['set-cookie']);
  }

  AccountEntity toEntity() => AccountEntity(accessToken);
}
