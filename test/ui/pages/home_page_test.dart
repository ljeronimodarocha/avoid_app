import 'dart:async';

import 'package:avoid_app/domain/entities/movie_entity.dart';
import 'package:avoid_app/ui/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class HomePresenterSpy extends Mock implements HomePresenter {}

late HomePresenter presenter;

late StreamController<String> mainErrorStreamController;
late StreamController<List<MovieEntity>> moviesStreamController;

void main() {
  void initStreams() {
    mainErrorStreamController = StreamController();
    moviesStreamController = StreamController();
  }

  void mockStreams() {
    when(() => presenter.mainErrorStream)
        .thenAnswer((_) => mainErrorStreamController.stream);
    when(() => presenter.movies)
        .thenAnswer((_) => moviesStreamController.stream);
    when(() => presenter.load()).thenAnswer((_) => Future.value());
  }

  void closeStreams() {
    moviesStreamController.close();
    mainErrorStreamController.close();
  }

  Future<void> loadPage(WidgetTester tester) async {
    presenter = HomePresenterSpy();
    initStreams();
    mockStreams();
    final signUpPage = GetMaterialApp(
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => HomePage(true, presenter)),
        GetPage(
            name: '/any_route',
            page: () => const Scaffold(body: Text('fake page')))
      ],
    );
    await tester.pumpWidget(signUpPage);
  }

  tearDown(() {
    closeStreams();
  });

  testWidgets('Should load page without movies', (tester) async {
    await loadPage(tester);
    moviesStreamController.add([MovieEntity(1, 'teste', 'teste')]);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should load page with movies loaded', (tester) async {
    await loadPage(tester);
    moviesStreamController.add([MovieEntity(1, 'testeNome', 'testeCategoria')]);
    await loadPage(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("testeNome"), findsOneWidget);
    expect(find.text("testeCategoria"), findsOneWidget);
  });
}
