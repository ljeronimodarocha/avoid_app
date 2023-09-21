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
    sut = GetXHomePresenter(loadMovies);
    mockLoadMovies()
        .thenAnswer((_) async => List.of([MovieEntity(1, 'teste', 'teste')]));
  });

  test('Should return list of movires', () async {
    var response = await sut.load();
    expect(response, isNot(null));
    expect(response.length, isNot(0));
    expect(response.length, 1);
  });

  test('Should return empty list', () async {
    mockLoadMovies().thenAnswer((_) async => List<MovieEntity>.empty());
    var response = await sut.load();
    expect(response, isNot(null));
    expect(response.length, 0);
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    mockLoadMovies().thenThrow(DomainError.unexpected);
    expectLater(sut.mainErrorStream,
        emitsInOrder(['Algo errado aconteceu. Tente novamente em breve']));

    await sut.load();
  });
}
