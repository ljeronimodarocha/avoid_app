import 'translation.dart';

class EnUs implements Translation {
  @override
  String get msgInvalidCredentials => 'Invalid credentials.';
  @override
  String get msgInvalidField => 'Invalid field';
  @override
  String get msgRequiredField => 'Required field';
  @override
  String get msgUnexpectedError => 'Something went wrong. Try again later.';

  @override
  String get confirmPassword => 'Confirm password';
  @override
  String get addAccount => 'Add account';
  @override
  String get name => 'Name';
  @override
  String get email => 'Email';
  @override
  String get enter => 'Enter';
  @override
  String get login => 'Login';
  @override
  String get password => 'Password';
  @override
  String get wait => 'Wait...';

  @override
  String get msgEmailInUse => 'E-mail in use.';

  @override
  String get reload => 'Reload';
}
