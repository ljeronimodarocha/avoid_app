import 'dart:async';

import 'package:get/state_manager.dart';

import '../../domain/entities/entities.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/pages/pages.dart';
import '../presentation.dart';

class GetXLoginPresenter extends GetxController implements LoginPresenter {
  String _email = '';
  String _password = '';

  final Validation validation;
  final Authentication authentication;
  final SaveCurrentAccount saveCurrentAccount;

  var _passwordError = RxString('');
  var _emailError = RxString('');
  var _mainError = RxString('');
  var _natigateTo = RxString('');
  var _isLoading = false.obs;
  var _isFormValid = false.obs;

  GetXLoginPresenter({
    required this.validation,
    required this.authentication,
    required this.saveCurrentAccount,
  });

  @override
  Stream<String> get emailErrorStream => _emailError.stream;
  @override
  Stream<String> get passwordErrorStream => _passwordError.stream;

  @override
  Stream<String> get mainErrorStream => _mainError.stream;

  @override
  Stream<String> get navigateToStream => _natigateTo.stream;

  @override
  Stream<bool> get isFormValidStream => _isFormValid.stream;

  @override
  Stream<bool> get isLoadingStream => _isLoading.stream;

  void _validateForm() {
    _isFormValid.value = _emailError.value.isEmpty &&
        _passwordError.value.isEmpty &&
        _email.isNotEmpty &&
        _password.isNotEmpty;
  }

  @override
  void validateEmail(String email) {
    _email = email;
    String? error = validation.validate(field: 'email', value: email);
    if (error != null && error.isNotEmpty) {
      _emailError.value = error;
    } else {
      _emailError.value = '';
    }
    _validateForm();
  }

  @override
  void validateSenha(String password) {
    _password = password;
    String? error = validation.validate(field: 'password', value: password);
    if (error != null && error.isNotEmpty) {
      _passwordError.value = error;
    } else {
      _passwordError.value = '';
    }
    _validateForm();
  }

  @override
  Future<void> auth() async {
    _isLoading.value = true;
    try {
      final AccountEntity accountEntity = await authentication
          .auth(AuthenticationParams(email: _email, secret: _password));
      await saveCurrentAccount.save(accountEntity);
      _natigateTo.value = '/surveys';
    } on DomainError catch (error) {
      _mainError.value = error.description;
      _isLoading.value = false;
    }
  }
}
