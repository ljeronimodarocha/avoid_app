import 'package:equatable/equatable.dart';

import '../../../presentation/presentation.dart';
import '../protocols/protocols.dart';

class EmailValidation extends Equatable implements FieldValidation {
  @override
  final String field;

  EmailValidation(this.field);

  List get props => [field];

  @override
  ValidationError? validate(Map input) {
    final regex = RegExp(
        r"^[a-zA-|0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-z0-9]+\.[a-zAz]+");
    final isValid =
        input[field]?.isNotEmpty != true || regex.hasMatch(input[field]);
    return isValid ? null : ValidationError.invalidField;
  }
}
