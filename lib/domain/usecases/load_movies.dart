import '../entities/movie_entity.dart';

abstract class load_movies {
  Future<List<MovieEntity>> load();
}
