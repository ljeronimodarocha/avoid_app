import '../entities/movie_entity.dart';

abstract class SaveMovie {
  Future<void> save(MovieEntity params);
}
