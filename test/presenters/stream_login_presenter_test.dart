import 'package:avoid_app/domain/entities/entities.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:avoid_app/presentation/presentation.dart';
import 'package:avoid_app/ui/helpers/helpers.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ValidationSpy extends Mock implements Validation {}

class AuthenticationSpy extends Mock implements Authentication {}

When mockValidationSpy(String field, Map value) =>
    when(() => validation.validate(field: field, input: value));

void mockValidationSpyData(String field, Map value, ValidationError? data) {
  mockValidationSpy(field, value).thenReturn(data);
}

When mockAuthenticationSpy() => when(() => authentication
    .auth(AuthenticationParams(userName: userName, secret: password)));

void mockAuthenticationSpyData() {
  mockAuthenticationSpy()
      .thenAnswer((_) async => AccountEntity(faker.guid.guid()));
}

late ValidationSpy validation;
late StreamLoginPresenter sut;
late String userName;
late String password;
late Authentication authentication;

void main() {
  setUp(() {
    validation = ValidationSpy();
    userName = faker.internet.userName();
    password = faker.internet.password();
    authentication = AuthenticationSpy();
    sut = StreamLoginPresenter(
        validation: validation, authentication: authentication);
    mockAuthenticationSpyData();
  });
  tearDown(() => sut.dispose());

  test('Should call Validation with correct userName', () {
    sut.validateUserName(userName);

    verify(() => validation.validate(
        field: 'userName',
        input: {'userName': userName, 'password': ''})).called(1);
  });

  test('Should emit userName error if validation fails 1', () {
    mockValidationSpy('userName', {'userName': 'error', 'password': ''})
        .thenReturn(ValidationError.invalidField);
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

  test('Should emit password error if validation fails1 ', () {
    mockValidationSpyData(
        'password',
        {'userName': userName, 'password': 'error'},
        ValidationError.invalidField);
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName(userName);
    sut.validateSenha('error');
    sut.validateSenha('error');
  });

  test('Should emit empty if validation password succeeds', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));
    sut.validateUserName(userName);
    sut.validateSenha(faker.internet.password());
    sut.validateSenha(faker.internet.password());
  });

  test(
      'Should emit password error if validation fails with all fields tested 11',
      () {
    mockValidationSpyData(
        'password',
        {'userName': 'error', 'password': password},
        ValidationError.invalidField);
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));
    sut.validateUserName(userName);
    sut.validateUserName('error');
    sut.validateSenha(password);
  });

  test('Should emit password error if validation fails', () {
    mockValidationSpyData(
        'password',
        {'userName': userName, 'password': 'error'},
        ValidationError.invalidField);
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateUserName(userName);
    sut.validateSenha('error');
  });

  test('Should emit empty if validation succeeds', () async {
    mockValidationSpyData(
        "userName", {'userName': userName, 'password': password}, null);
    mockValidationSpyData(
        "password", {'userName': userName, 'password': password}, null);
    sut.userNameErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));

    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateUserName(userName);
    sut.validateSenha(password);
  });

  test('Should call Authentication with correct values', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    await sut.auth();

    verify(() => authentication
            .auth(AuthenticationParams(userName: userName, secret: password))
        as Function()).called(1);
  });

  test('Should emit corrrect events on Authentication success', () async {
    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    await sut.auth();
  });

  test('Should emit corrrect events on InvalidCredentialsError', () async {
    mockAuthenticationSpy().thenThrow(DomainError.invalidCredentials);

    sut.validateUserName(userName);

    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    expectLater(
        sut.mainErrorStream, emitsInOrder(['', 'Credencias inválidas.']));

    await sut.auth();
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    mockAuthenticationSpy().thenThrow(DomainError.unexpected);

    sut.validateUserName(userName);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    expectLater(sut.mainErrorStream,
        emitsInOrder(['', 'Algo errado aconteceu. Tente novamente em breve']));

    await sut.auth();
  });

  test('Should not emit after dispose', () async {
    expectLater(sut.mainErrorStream, neverEmits(''));
    sut.dispose();
    sut.validateUserName(userName);
  });
}
