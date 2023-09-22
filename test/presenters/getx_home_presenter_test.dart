import 'dart:math';

import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/load_movies.dart';
import 'package:avoid_app/presentation/presenters/getx_home_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadMoviesSpy extends Mock implements LoadMovies {}

void main() {
  late LoadMovies loadMovies;
  late GetXHomePresenter sut;
  When mockLoadMovies() => when(() => loadMovies.load());

  setUp(() {
    loadMovies = LoadMoviesSpy();
    sut = GetXHomePresenter(loadMovies: loadMovies);
    mockLoadMovies()
        .thenAnswer((_) async => List.of([MovieEntity(1, 'teste', 'teste')]));
  });

  test('Should return list of movires', () async {
    await sut.load();
    var quantidade = await sut.movies.length;
    log(quantidade);
    expect(quantidade, completion(isNot(null)));
    expect(quantidade, completion(isNot(0)));
    expect(quantidade, completion(1));
  });

  test('Should return empty list', () async {
    mockLoadMovies().thenAnswer((_) async => List<MovieEntity>.empty());
    await sut.load();
    final quantidade = await sut.movies.length;
    expect(quantidade, isNot(null));
    expect(quantidade, 0);
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    mockLoadMovies().thenThrow(DomainError.unexpected);
    expectLater(sut.mainErrorStream,
        emitsInOrder(['Algo errado aconteceu. Tente novamente em breve']));

    await sut.load();
  });
}
