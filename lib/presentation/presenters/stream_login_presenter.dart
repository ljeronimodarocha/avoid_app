import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/authentication.dart';
import '../../ui/pages/pages.dart';
import '../presentation.dart';

class LoginState {
  String userName = "";
  String password = "";

  late String emailError = "";
  late String passwordError = "";
  late String mainError = "";
  late String navigateTo = "";

  bool isLoading = false;

  bool get isFormValid =>
      emailError.isEmpty &&
      passwordError.isEmpty &&
      userName.isNotEmpty &&
      password.isNotEmpty;
}

class StreamLoginPresenter implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;
  final _controller = StreamController<LoginState>.broadcast();

  final _state = LoginState();

  StreamLoginPresenter(
      {required this.validation, required this.authentication});

  @override
  Stream<String> get userNameErrorStream =>
      _controller.stream.map((state) => state.emailError).distinct();
  @override
  Stream<String> get passwordErrorStream =>
      _controller.stream.map((state) => state.passwordError).distinct();

  @override
  Stream<String> get mainErrorStream =>
      _controller.stream.map((state) => state.mainError).distinct();
  @override
  Stream<String> get navigateToStream =>
      _controller.stream.map((state) => state.navigateTo).distinct();

  @override
  Stream<bool> get isFormValidStream =>
      _controller.stream.map((state) => state.isFormValid).distinct();

  @override
  Stream<bool> get isLoadingStream =>
      _controller.stream.map((state) => state.isLoading).distinct();

  void _update() {
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  @override
  void validateUserName(String userName) {
    _state.userName = userName;
    String? error = validation.validate(field: 'userName', value: userName);
    if (error != null && error.isNotEmpty) {
      _state.emailError = error;
    } else {
      _state.emailError = '';
    }
    _update();
  }

  @override
  void validateSenha(String password) {
    _state.password = password;
    String? error = validation.validate(field: 'password', value: password);
    if (error != null && error.isNotEmpty) {
      _state.passwordError = error;
    } else {
      _state.passwordError = '';
    }
    _update();
  }

  @override
  Future<void> auth() async {
    _state.isLoading = true;
    _update();
    await Future.delayed(Duration.zero);
    try {
      await authentication.auth(AuthenticationParams(
          userName: _state.userName, secret: _state.password));
    } on DomainError catch (error) {
      _state.mainError = error.description;
    }
    _state.isLoading = false;
    _update();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
