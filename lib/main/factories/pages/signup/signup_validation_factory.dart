import '../../../../presentation/protocols/validation.dart';
import '../../../../ui/validation/protocols/protocols.dart';
import '../../../../ui/validation/validators/validators.dart';
import '../../../builders/builders.dart';

Validation makeSignUpValidation() =>
    ValidationComposite(makeSignUpValidations());

List<FieldValidation> makeSignUpValidations() => [
      ...ValidationBuilder.field('name').required().build(),
      ...ValidationBuilder.field('email').required().email().build(),
      ...ValidationBuilder.field('password').required().build(),
      ...ValidationBuilder.field('passwordConfirmation')
          .required()
          .sameAs('password')
          .build()
    ];
