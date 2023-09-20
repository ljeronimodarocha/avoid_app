import 'package:avoid_app/data/http/http.dart';
import 'package:avoid_app/data/usecases/save_movie/remote_save_movie.dart';
import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  MovieEntity movie = MovieEntity('teste', 'teste');
  Map body = {"nome": movie.nome, "categoria": movie.categoria};
  late RemoteSaveMovie sut;
  late HttpClientSpy clientSpy;
  String url = '/movie';

  When mockRequest() =>
      when(() => clientSpy.request(url: '/movie', method: 'POST', body: body));
  setUp(() {
    clientSpy = HttpClientSpy();
    sut = RemoteSaveMovie(clientSpy, url);
    mockRequest().thenAnswer((_) => Future.value({"statusCode": 200}));
  });

  test('Should save movie with correct values', () {
    sut.save(movie);
    verify(() => clientSpy.request(url: url, method: 'POST', body: body))
        .called(1);
  });
}
