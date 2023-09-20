import 'package:avoid_app/domain/entities/entities.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:avoid_app/presentation/presentation.dart';
import 'package:avoid_app/ui/helpers/helpers.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ValidationSpy extends Mock implements Validation {
  ValidationError? error;

  ValidationSpy({this.error});

  @override
  ValidationError? validate({required String field, required Map input}) {
    super.noSuchMethod(Invocation.method(#validate, [field, input]));
    if (input[field] == 'error') {
      return ValidationError.invalidField;
    }
    return null;
  }
}

class AuthenticationSpy extends Mock implements Authentication {
  DomainError? error;

  AuthenticationSpy([this.error]);

  @override
  Future<AccountEntity> auth(AuthenticationParams params) async {
    super.noSuchMethod(Invocation.method(#auth, [params]));
    if (error != null) {
      throw error!;
    }
    return Future.value(AccountEntity(token));
  }
}

class SaveCurrentAccountSpy extends Mock implements SaveCurrentAccount {
  Exception? error;

  SaveCurrentAccountSpy([this.error]);
  @override
  Future<void> save(AccountEntity account) async {
    super.noSuchMethod(Invocation.method(#save, [account]));
    if (error != null) {
      throw error!;
    }
  }
}

final token = faker.guid.guid();

void main() {
  late ValidationSpy validation;
  late GetXLoginPresenter sut;
  late String userName;
  late String password;
  late Authentication authentication;
  late SaveCurrentAccount saveCurrentAccount;

  setUp(() {
    validation = ValidationSpy();
    userName = faker.internet.userName();
    password = faker.internet.password();
    authentication = AuthenticationSpy();
    saveCurrentAccount = SaveCurrentAccountSpy();

    sut = GetXLoginPresenter(
        validation: validation,
        authentication: authentication,
        saveCurrentAccount: saveCurrentAccount);
  });

  test('Should call Validation with correct userName', () {
    sut.validateUserName(userName);

    verify(() => validation.validate(
        field: 'userName',
        input: {'userName': userName, 'password': ''})).called(1);
  });

  test('Should emit userName error if validation fails', () {
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName('error');
    sut.validateUserName('error');
  });

  test('Should emit empty if validation userName succeeds', () {
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName(faker.internet.userName());
    sut.validateUserName(faker.internet.userName());
  });

  test('Should call Validation with correct password', () {
    sut.validateSenha(password);

    verify(() => validation.validate(
        field: 'password',
        input: {'userName': '', 'password': password})).called(1);
  });

  test('Should emit password error if validation fails 2', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateSenha('error');
    sut.validateSenha('error');
  });

  test('Should emit empty if validation password succeeds', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateSenha(faker.internet.password());
    sut.validateSenha(faker.internet.password());
  });

  test('Should emit password error if validation fails', () {
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName(faker.internet.email());
    sut.validateSenha('error');
  });

  test('Should emit userName error if validation fails 2', () {
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName(faker.internet.userName());
    sut.validateSenha('error');
  });

  test('Should emit empty if validation succeeds', () async {
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));

    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateUserName(faker.internet.userName());
    await Future.delayed(Duration.zero);
    sut.validateSenha(faker.internet.password());
  });

  test('Should call Authentication with correct values', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    await sut.auth();

    verify(() => authentication.auth(
        AuthenticationParams(userName: userName, secret: password))).called(1);
  });

  test('Should call SaveCurrentAccount with correct value', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    await sut.auth();

    verify(() => saveCurrentAccount.save(AccountEntity(token))).called(1);
  });

  test('Should emit UnexpectedError if SaveCurrentAccount fails', () async {
    when(() => saveCurrentAccount.save(AccountEntity(token)))
        .thenThrow(DomainError.unexpected);

    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.mainErrorStream.listen(expectAsync1((error) =>
        expect(error, 'Algo errado aconteceu. Tente novamente em breve')));

    await sut.auth();
  });

  test('Should emit corrrect events on Authentication success', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true]));

    await sut.auth();
  });

  test('Should emit corrrect events on InvalidCredentialsError', () async {
    sut = GetXLoginPresenter(
        validation: validation,
        authentication: AuthenticationSpy(DomainError.invalidCredentials),
        saveCurrentAccount: saveCurrentAccount);

    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.mainErrorStream.listen(
        expectAsync1((error) => expect(error, 'Credencias inválidas.')));

    await sut.auth();
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    when(() => saveCurrentAccount.save(AccountEntity(token)))
        .thenThrow(DomainError.unexpected);

    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.mainErrorStream.listen(expectAsync1((error) =>
        expect(error, 'Algo errado aconteceu. Tente novamente em breve')));

    await sut.auth();
  });

  test('Sould change page on success', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/video')));
    await sut.auth();
  });

  test('Should go to SignUpPage on link click', () async {
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/signup')));

    sut.goToSignUp();
  });
}
