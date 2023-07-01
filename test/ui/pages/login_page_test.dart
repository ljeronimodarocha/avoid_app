import 'dart:async';

import 'package:avoid_app/ui/pages/login/login_page.dart';
import 'package:avoid_app/ui/pages/login/login_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoginPresenterSpy extends Mock implements LoginPresenter {}

late LoginPresenter presenter;
void initStreams() {
  emailErrorController = StreamController<String>();
  passwordErrorController = StreamController<String>();
  mainErrorController = StreamController<String>();

  isFormValidController = StreamController<bool>();
  isLoadingController = StreamController<bool>();
}

late StreamController<String> emailErrorController;
late StreamController<String> passwordErrorController;
late StreamController<String> mainErrorController;

late StreamController<bool> isFormValidController;
late StreamController<bool> isLoadingController;
void main() {
  setUp(() {
    initStreams();
    presenter = LoginPresenterSpy();
    when(() => presenter.emailErrorStream)
        .thenAnswer((_) => emailErrorController.stream);

    when(() => presenter.passwordErrorStream)
        .thenAnswer((_) => passwordErrorController.stream);

    when(() => presenter.mainErrorStream)
        .thenAnswer((_) => mainErrorController.stream);

    when(() => presenter.isFormValidStream)
        .thenAnswer((_) => isFormValidController.stream);

    when(() => presenter.isLoadingStream)
        .thenAnswer((_) => isLoadingController.stream);
  });
  Future<void> loadPage(WidgetTester tester) async {
    final loginPage = MaterialApp(home: LoginPage(presenter));
    await tester.pumpWidget(loginPage);
  }

  testWidgets('Should load with corret initial state', (tester) async {
    await loadPage(tester);

    final emailTextChildren = find.descendant(
        of: find.bySemanticsLabel('Email'), matching: find.byType(Text));

    expect(emailTextChildren, findsOneWidget,
        reason:
            'when a TextFormField has only text child, means it has no errors, since one of the childs is aways the label text');

    final passwordTextChildren = find.descendant(
        of: find.bySemanticsLabel('Senha'), matching: find.byType(Text));

    expect(passwordTextChildren, findsOneWidget,
        reason:
            'when a TextFormField has only text child, means it has no errors, since one of the childs is aways the label text');

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, null);

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
