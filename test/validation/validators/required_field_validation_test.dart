import 'package:avoid_app/presentation/presentation.dart';
import 'package:avoid_app/ui/validation/validators/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RequiredFieldValidation sut;
  setUp(() {
    sut = RequiredFieldValidation('any_field');
  });

  test('Should return null if value is not empty', () {
    final error = sut.validate({'any_field': 'any_value'});
    expect(error, null);
  });

  test('Should return error if value is empty', () {
    final error = sut.validate({'teste': ''});
    expect(error, ValidationError.requiredField);
  });
}
