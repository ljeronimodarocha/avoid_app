import 'package:avoid_app/ui/helpers/i18n/strings/strings.dart';

class PtBr implements Translation {
  @override
  String get msgEmailInUse => 'O email já está em uso.';
  @override
  String get msgInvalidCredentials => 'Credenciais inválidas.';
  @override
  String get msgInvalidField => 'Campo inválido';
  @override
  String get msgRequiredField => 'Campo obrigatório';
  @override
  String get msgUnexpectedError =>
      'Algo errado aconteceu. Tente novamente em breve.';

  @override
  String get confirmPassword => 'Confirmar senha';
  @override
  String get addAccount => 'Criar conta';
  @override
  String get name => 'Nome';
  @override
  String get email => 'Email';
  @override
  String get enter => 'Entrar';
  @override
  String get login => 'Login';
  @override
  String get password => 'Senha';
  @override
  String get wait => 'Aguarde...';
  @override
  String get reload => 'Recarregar';
}
