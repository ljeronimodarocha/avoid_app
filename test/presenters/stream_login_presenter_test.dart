import 'package:avoid_app/domain/entities/entities.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/usecases.dart';
import 'package:avoid_app/presentation/presentation.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class ValidationSpy extends Mock implements Validation {}

class AuthenticationSpy extends Mock implements Authentication {}

When mockValidationSpy(String field, String value) =>
    when(() => validation.validate(field: field, value: value));

void mockValidationSpyData(String field, String value, String data) {
  mockValidationSpy(field, value).thenReturn(data);
}

When mockAuthenticationSpy() => when(() =>
    authentication.auth(AuthenticationParams(email: email, secret: password)));

void mockAuthenticationSpyData() {
  mockAuthenticationSpy()
      .thenAnswer((_) async => AccountEntity(faker.guid.guid()));
}

late ValidationSpy validation;
late StreamLoginPresenter sut;
late String email;
late String password;
late Authentication authentication;

void main() {
  setUp(() {
    validation = ValidationSpy();
    email = faker.internet.email();
    password = faker.internet.password();
    authentication = AuthenticationSpy();
    sut = StreamLoginPresenter(
        validation: validation, authentication: authentication);
    mockAuthenticationSpyData();
  });
  tearDown(() => sut.dispose());

  test('Should call Validation with correct email', () {
    sut.validateEmail(email);

    verify(() => validation.validate(field: 'email', value: email)).called(1);
  });

  test('Should emit email error if validation fails', () {
    mockValidationSpyData('email', 'error', 'error');
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail('error');
    sut.validateEmail('error');
  });

  test('Should emit empty if validation email succeeds', () {
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(faker.internet.email());
    sut.validateEmail(faker.internet.email());
  });

  test('Should call Validation with correct password', () {
    sut.validateSenha(password);

    verify(() => validation.validate(field: 'password', value: password)
        as Function()).called(1);
  });

  test('Should emit password error if validation fails', () {
    mockValidationSpyData('password', 'error', 'error');
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateSenha('error');
    sut.validateSenha('error');
  });

  test('Should emit empty if validation password succeeds', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateSenha(faker.internet.password());
    sut.validateSenha(faker.internet.password());
  });

  test('Should emit password error if validation fails with all fields tested',
      () {
    mockValidationSpyData('email', 'error', 'error');
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail('error');
    sut.validateSenha(faker.internet.password());
  });

  test('Should emit password error if validation fails', () {
    mockValidationSpyData('password', 'error', 'error');
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(faker.internet.email());
    sut.validateSenha('error');
  });

  test('Should emit empty if validation succeeds', () async {
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, isEmpty)));

    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateEmail(faker.internet.email());
    await Future.delayed(Duration.zero);
    sut.validateSenha(faker.internet.password());
  });

  test('Should call Authentication with correct values', () async {
    sut.validateEmail(email);
    sut.validateSenha(password);

    await sut.auth();

    verify(() => authentication
            .auth(AuthenticationParams(email: email, secret: password))
        as Function()).called(1);
  });

  test('Should emit corrrect events on Authentication success', () async {
    sut.validateEmail(email);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    await sut.auth();
  });

  test('Should emit corrrect events on InvalidCredentialsError', () async {
    mockAuthenticationSpy().thenThrow(DomainError.invalidCredentials);

    sut.validateEmail(email);

    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    expectLater(
        sut.mainErrorStream, emitsInOrder(['', 'Credencias inválidas.']));

    await sut.auth();
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    mockAuthenticationSpy().thenThrow(DomainError.unexpected);

    sut.validateEmail(email);
    sut.validateSenha(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    expectLater(sut.mainErrorStream,
        emitsInOrder(['', 'Algo errado aconteceu. Tente novamente em breve']));

    await sut.auth();
  });

  test('Should not emit after dispose', () async {
    expectLater(sut.mainErrorStream, neverEmits(''));
    sut.dispose();
    sut.validateEmail(email);
  });
}
