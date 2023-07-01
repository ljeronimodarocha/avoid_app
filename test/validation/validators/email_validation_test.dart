import 'package:avoid_app/validation/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EmailValidation sut;
  setUp(() {
    sut = EmailValidation('any_field');
  });

  test('Should return null if email is empty', () {
    final error = sut.validate('');

    expect(error, null);
  });

  test('Should return null if email is null', () {
    final error = sut.validate('');

    expect(error, null);
  });

  test('Should return null if email is valid', () {
    final error = sut.validate("fernando.mateus.moreira@almaquinas.com.br");

    expect(error, null);
  });

  test('Should return null if email is invalid', () {
    final error = sut.validate('teste');

    expect(error, 'Campo inválido');
  });
}
