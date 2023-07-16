import '../../../../validation/protocols/protocols.dart';
import '../../../../validation/validators/validators.dart';
import '../../../builders/builders.dart';

ValidationComposite makeValidationComposite() {
  return ValidationComposite(makeLoginValidations());
}

List<FieldValidation> makeLoginValidations() {
  return [
    ...ValidationBuilder.field('username').required().build(),
    ...ValidationBuilder.field('password').required().build()
  ];
}
