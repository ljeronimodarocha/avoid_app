import 'dart:async';

import 'package:get/state_manager.dart';

import '../../domain/entities/entities.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';
import '../presentation.dart';

class GetXLoginPresenter extends GetxController implements LoginPresenter {
  String _userName = '';
  String _password = '';

  final Validation validation;
  final Authentication authentication;
  final SaveCurrentAccount saveCurrentAccount;

  var _userNameError = Rx<UIError?>(null);
  var _passwordError = Rx<UIError?>(null);

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
  Stream<UIError?> get userNameErrorStream => _userNameError.stream;
  @override
  Stream<UIError?> get passwordErrorStream => _passwordError.stream;

  @override
  Stream<String> get mainErrorStream => _mainError.stream;

  @override
  Stream<String> get navigateToStream => _natigateTo.stream;

  @override
  Stream<bool> get isFormValidStream => _isFormValid.stream;

  @override
  Stream<bool> get isLoadingStream => _isLoading.stream;

  void _validateForm() {
    _isFormValid.value = _userNameError.value == null &&
        _passwordError.value == null &&
        _userName.isNotEmpty &&
        _password.isNotEmpty;
  }

  @override
  void validateUserName(String userName) {
    _userName = userName;
    _userNameError.value = _validateField('userName');

    _validateForm();
  }

  UIError? _validateField(String field) {
    final formData = {
      'userName': _userName,
      'password': _password,
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
  void validateSenha(String password) {
    _password = password;
    _passwordError.value = _validateField('password');

    _validateForm();
  }

  @override
  Future<void> auth() async {
    _isLoading.value = true;
    try {
      final AccountEntity accountEntity = await authentication
          .auth(AuthenticationParams(userName: _userName, secret: _password));
      await saveCurrentAccount.save(accountEntity);
      _natigateTo.value = '/video';
    } on DomainError catch (error) {
      _mainError.value = error.description;
      _isLoading.value = false;
    }
  }

  @override
  void goToSignUp() {
    _natigateTo.value = '/signup';
  }
}
