import 'package:avoid_app/presentation/presentation.dart';

abstract class FieldValidation {
  String get field;
  ValidationError? validate(Map input);
}
