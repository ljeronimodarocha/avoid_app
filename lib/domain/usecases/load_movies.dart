import '../entities/movie_entity.dart';

abstract class LoadMovies {
  Future<List<MovieEntity>> load();
}
