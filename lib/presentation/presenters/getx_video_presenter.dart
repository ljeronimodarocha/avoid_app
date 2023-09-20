import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/domain/usecases/save_movie.dart';
import 'package:get/get.dart';

import '../../domain/helpers/helpers.dart';
import '../../ui/helpers/errors/ui_error.dart';
import '../../ui/pages/video/video.dart';
import '../protocols/validation.dart';

class GetXVideoPresenter implements VideoPresenter {
  String _filmeName = '';
  String _filmeCategoria = '';

  var _nameError = Rx<UIError?>(null);
  var _categoryError = Rx<UIError?>(null);

  var _isFormValid = false.obs;

  var _mainError = RxString('');
  var _natigateTo = RxString('');
  var _isLoading = false.obs;

  final Validation validation;
  final SaveMovie save;
  GetXVideoPresenter({required this.validation, required this.save});

  @override
  Stream<UIError?> get categoriaErrorStream => _categoryError.stream;

  @override
  Stream<UIError?> get nameErrorStream => _nameError.stream;

  @override
  Stream<bool> get isFormValidStream => _isFormValid.stream;

  @override
  Stream<bool> get isLoadingStream => _isLoading.stream;

  @override
  Stream<String> get mainErrorStream => _mainError.stream;

  @override
  Stream<String> get navigateToStream => _natigateTo.stream;

  UIError? _validateField(String field) {
    final formData = {
      'name': _filmeName,
      'category': _filmeCategoria,
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
  Future<void> saveMovie() async {
    _isLoading.value = true;
    try {
      await save.save(MovieEntity(_filmeName, _filmeCategoria));
      _natigateTo.value = '/home';
    } on DomainError catch (error) {
      _mainError.value = error.description;
      _isLoading.value = false;
    }
  }

  void _validateForm() {
    _isFormValid.value = _nameError.value == null &&
        _categoryError.value == null &&
        _filmeName.isNotEmpty &&
        _filmeCategoria.isNotEmpty;
  }

  @override
  void validateCategory(String categoria) {
    _filmeCategoria = categoria;
    _categoryError.value = _validateField('category');

    _validateForm();
  }

  @override
  void validateName(String name) {
    _filmeName = name;
    _nameError.value = _validateField('name');

    _validateForm();
  }
}
