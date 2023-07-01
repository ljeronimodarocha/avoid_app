import 'package:avoid_app/domain/entities/entities.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:avoid_app/presentation/presentation.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadCurrentAccountSpy extends Mock implements LoadCurrentAccount {
  DomainError? error;

  String? token;

  LoadCurrentAccountSpy({this.error, this.token});

  @override
  Future<AccountEntity> load() async {
    super.noSuchMethod(Invocation.method(#load, []));
    if (error != null) {
      throw DomainError.unexpected;
    } else if (token != null) {
      return AccountEntity(token!);
    }
    return AccountEntity(faker.guid.guid());
  }
}

void main() {
  late LoadCurrentAccount loadCurrentAccount;
  late GetxSplashPresenter sut;
  setUp(() {
    loadCurrentAccount = LoadCurrentAccountSpy();
    sut = GetxSplashPresenter(loadCurrentAccount: loadCurrentAccount);
  });
  test('Should call LoadCurrentAccount', () async {
    await sut.checktAccount(durationInSeconds: 0);
    verify(() => loadCurrentAccount.load()).called(1);
  });

  test('Should go to surveys page on success', () async {
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/surveys')));
    await sut.checktAccount(durationInSeconds: 0);
  });

  test('Should go to login page on empty result ', () async {
    loadCurrentAccount = LoadCurrentAccountSpy(token: '');
    sut = GetxSplashPresenter(loadCurrentAccount: loadCurrentAccount);
    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));
    await sut.checktAccount(durationInSeconds: 0);
  });

  test('Should go to login page on error ', () async {
    loadCurrentAccount =
        LoadCurrentAccountSpy(error: DomainError.invalidCredentials);
    sut = GetxSplashPresenter(loadCurrentAccount: loadCurrentAccount);
    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));
    await sut.checktAccount(durationInSeconds: 0);
  });
}
