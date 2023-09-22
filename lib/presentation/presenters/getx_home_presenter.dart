import 'package:get/get.dart';

import '../../domain/entities/movie_entity.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/load_movies.dart';
import '../../ui/pages/home/home_presenter.dart';

class GetXHomePresenter implements HomePresenter {
  LoadMovies loadMovies;

  var _mainError = RxString('');
  var _listMovies = RxList<MovieEntity>();
  @override
  Stream<String> get mainErrorStream => _mainError.stream;
  GetXHomePresenter({required this.loadMovies});

  @override
  Future<void> load() async {
    try {
      final response = await loadMovies.load();
      _listMovies.value = response;
    } on DomainError catch (error) {
      _mainError.value = error.description;
    }
  }

  @override
  Stream<List<MovieEntity>> get movies => _listMovies.stream;
}
