import '../../../data/usecases/add_account/add_account.dart';
import '../../../data/usecases/usecases.dart';
import '../../../domain/usecases/usecases.dart';
import '../factories.dart';

AddAccount makeRemoteAddAccount() =>
    RemoteAddAccount(httpClient: makeHttpAdapter(), url: makeApiUrl('signup'));
