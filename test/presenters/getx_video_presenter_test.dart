import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/domain/helpers/helpers.dart';
import 'package:avoid_app/domain/usecases/save_movie.dart';
import 'package:avoid_app/presentation/presentation.dart';
import 'package:avoid_app/presentation/presenters/getx_video_presenter.dart';
import 'package:avoid_app/ui/helpers/helpers.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ValidationSpy extends Mock implements Validation {
  ValidationError? error;

  ValidationSpy({this.error});

  @override
  ValidationError? validate({required String field, required Map input}) {
    super.noSuchMethod(Invocation.method(#validate, [field, input]));
    if (input[field] == 'error') {
      return ValidationError.invalidField;
    }
    return null;
  }
}

class SaveFilmeSpy extends Mock implements SaveMovie {
  @override
  Future<void> save(MovieEntity filme) async {
    super.noSuchMethod(Invocation.method(#save, []));
    Future.value();
  }
}

void main() {
  late GetXVideoPresenter sut;
  late SaveMovie saveFilmeSpy;
  late Validation validationSpy;

  final String name = faker.person.name();
  final String categoria = faker.randomGenerator.string(10);

  setUp(() {
    saveFilmeSpy = SaveFilmeSpy();
    validationSpy = ValidationSpy();
    sut = GetXVideoPresenter(validation: validationSpy, save: saveFilmeSpy);
  });

  test('Should emit corrrect events on UnexpectedError', () async {
    when(() => saveFilmeSpy.save(MovieEntity(1, name, categoria)))
        .thenThrow(DomainError.unexpected);

    sut.validateName(name);
    sut.validateCategory(categoria);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.mainErrorStream.listen(expectAsync1((error) =>
        expect(error, 'Algo errado aconteceu. Tente novamente em breve')));

    await sut.saveMovie();
  });

  test('Shoud emit categoria error', () {
    sut.nameErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.categoriaErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateName(name);
    sut.validateCategory('error');
  });

  test('Shoud emit name error', () {
    sut.nameErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.categoriaErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateName('error');
    sut.validateCategory(categoria);
  });

  test('Should save filme with correct values', () async {
    sut.validateName(name);
    sut.validateCategory(categoria);

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/home')));

    sut.saveMovie();
    verify(() => saveFilmeSpy.save(MovieEntity(1, name, categoria)));
  });
}
