import '../../helpers/helpers.dart';

abstract class LoginPresenter {
  Stream<UIError?> get userNameErrorStream;
  Stream<UIError?> get passwordErrorStream;
  Stream<String> get mainErrorStream;
  Stream<String> get navigateToStream;

  Stream<bool> get isFormValidStream;
  Stream<bool> get isLoadingStream;

  void validateUserName(String email);
  void validateSenha(String senha);

  Future<void> auth();
  void goToSignUp();
  void dispose();
}
