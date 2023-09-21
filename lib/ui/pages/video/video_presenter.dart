import '../../helpers/errors/ui_error.dart';

abstract class SaveMoviePresenter {
  Stream<UIError?> get nameErrorStream;
  Stream<UIError?> get categoriaErrorStream;
  Stream<String> get mainErrorStream;
  Stream<String> get navigateToStream;

  Stream<bool> get isFormValidStream;
  Stream<bool> get isLoadingStream;

  void validateName(String name);
  void validateCategory(String category);

  Future<void> saveMovie();
}
