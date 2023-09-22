import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/authentication.dart';
import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';
import '../presentation.dart';

class LoginState {
  String userName = "";
  String password = "";

  late UIError? emailError;
  late UIError? passwordError;
  late String mainError = "";
  late String navigateTo = "";

  bool isLoading = false;

  bool get isFormValid =>
      emailError != null &&
      passwordError != null &&
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
  Stream<UIError?> get userNameErrorStream {
    _controller.stream.map((state) {
      if (state.emailError != null) return state.emailError;
    });
    return const Stream.empty();
  }

  Stream<UIError?> get passwordErrorStream {
    _controller.stream.map((state) {
      if (state.passwordError != null) return state.passwordError;
    });
    return const Stream.empty();
  }

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

  UIError? _validateField(String field) {
    final formData = {
      'userName': _state.userName,
      'password': _state.password,
    };
    final error = validation.validate(field: field, input: formData);
    switch (error) {
      case ValidationError.invalidField:
        return UIError.invalidField;
      case ValidationError.requiredField:
        return UIError.requiredField;
      default:
        return null;
    }
  }

  @override
  void validateUserName(String userName) {
    _state.userName = userName;
    _state.emailError = _validateField('userName');

    _update();
  }

  @override
  void validateSenha(String password) {
    _state.password = password;
    _state.passwordError = _validateField('password');

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
  void goToSignUp() {
    _state.navigateTo = '/signup';
    _update();
  }

  @override
  void goToLogin() {
    _state.navigateTo = '/signup';
    _update();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
