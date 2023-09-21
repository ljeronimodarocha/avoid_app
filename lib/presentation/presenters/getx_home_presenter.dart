import 'package:get/get.dart';

import '../../domain/entities/movie_entity.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/load_movies.dart';
import '../../ui/pages/home/home_presenter.dart';

class GetXHomePresenter implements HomePresenter {
  LoadMovies _loadMovies;

  var _mainError = RxString('');
  @override
  Stream<String> get mainErrorStream => _mainError.stream;
  GetXHomePresenter(this._loadMovies);

  @override
  Future<List<MovieEntity>> load() async {
    try {
      final response = await _loadMovies.load();
      return response;
    } on DomainError catch (error) {
      _mainError.value = error.description;
    }
    return List<MovieEntity>.empty();
  }
}
