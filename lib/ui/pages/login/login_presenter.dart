abstract class LoginPresenter {
  Stream<String> get userNameErrorStream;
  Stream<String> get passwordErrorStream;
  Stream<String> get mainErrorStream;
  Stream<String> get navigateToStream;

  Stream<bool> get isFormValidStream;
  Stream<bool> get isLoadingStream;

  void validateUserName(String email);
  void validateSenha(String senha);

  Future<void> auth();
  void dispose();
}
