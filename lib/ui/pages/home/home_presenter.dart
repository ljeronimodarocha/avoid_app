import 'package:avoid_app/domain/entities/movie_entity.dart';

abstract class HomePresenter {
  Stream<List<MovieEntity>> get movies;

  Stream<String> get mainErrorStream;

  Future<void> load();
}
