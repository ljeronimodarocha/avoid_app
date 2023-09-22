import '../../ui/validation/protocols/protocols.dart';
import '../../ui/validation/validators/compare_fields_validation.dart';
import '../../ui/validation/validators/validators.dart';

class ValidationBuilder {
  static late ValidationBuilder _instance;
  late String fieldName;
  List<FieldValidation> validations = [];

  ValidationBuilder._();

  static ValidationBuilder field(String fieldName) {
    _instance = ValidationBuilder._();
    _instance.fieldName = fieldName;
    return _instance;
  }

  ValidationBuilder required() {
    validations.add(RequiredFieldValidation(fieldName));
    return this;
  }

  ValidationBuilder email() {
    validations.add(EmailValidation(fieldName));
    return this;
  }

  ValidationBuilder sameAs(String fieldToCompare) {
    validations.add(CompareFieldsValidation(
        field: fieldName, fieldToCompare: fieldToCompare));
    return this;
  }

  List<FieldValidation> build() => validations;
}
