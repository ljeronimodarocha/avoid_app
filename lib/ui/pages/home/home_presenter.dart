import 'package:avoid_app/domain/entities/movie_entity.dart';

abstract class HomePresenter {
  Stream<String> get mainErrorStream;

  Future<List<MovieEntity>> load();
}
