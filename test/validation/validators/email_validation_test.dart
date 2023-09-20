import 'package:avoid_app/presentation/presentation.dart';
import 'package:avoid_app/ui/validation/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EmailValidation sut;
  setUp(() {
    sut = EmailValidation('email');
  });

  test('Should return null if email is empty', () {
    final error = sut.validate({'email': ''});

    expect(error, null);
  });

  test('Should return null if email is null', () {
    final error = sut.validate({'email': ''});

    expect(error, null);
  });

  test('Should return null if email is valid', () {
    final error =
        sut.validate({"email": "fernando.mateus.moreira@almaquinas.com.br"});

    expect(error, null);
  });

  test('Should return null if email is invalid', () {
    final error = sut.validate({'email': 'teste'});

    expect(error, ValidationError.invalidField);
  });
}
