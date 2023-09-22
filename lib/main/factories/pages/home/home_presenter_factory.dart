import 'package:avoid_app/main/factories/usescases/load_movies_factory.dart';
import 'package:avoid_app/presentation/presenters/getx_home_presenter.dart';

GetXHomePresenter makeGetXLoginPresenter() {
  return GetXHomePresenter(loadMovies: makeLoadMovies());
}
