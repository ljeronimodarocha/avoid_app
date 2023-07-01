import 'package:avoid_app/validation/protocols/protocols.dart';
import 'package:avoid_app/validation/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FieldValidationSpy extends Mock implements FieldValidation {
  @override
  String field;

  String? error;
  FieldValidationSpy([this.field = "any_field", this.error]);

  @override
  String? validate(String? value) {
    if (error != null && error!.isNotEmpty) {
      return error;
    }
    return null;
  }
}

void main() {
  late FieldValidationSpy validation1;
  late FieldValidationSpy validation2;
  late FieldValidationSpy validation3;
  late ValidationComposite sut;
  setUp(() {
    validation1 = FieldValidationSpy();
    validation2 = FieldValidationSpy();
    validation3 = FieldValidationSpy();
    sut = ValidationComposite([validation1, validation2]);
  });

  test('Should return null if all validations returns null or empty', () {
    final error = sut.validate(field: 'any_field', value: 'any_value');

    expect(error, null);
  });

  test('Should return the first error', () {
    validation1 = FieldValidationSpy('any_field');
    validation2 = FieldValidationSpy('any_field', "error_2");
    validation3 = FieldValidationSpy('error_3', "error_3");
    sut = ValidationComposite([validation1, validation2, validation3]);
    final error = sut.validate(field: 'any_field', value: 'any_value');

    expect(error, 'error_2');
  });
}
