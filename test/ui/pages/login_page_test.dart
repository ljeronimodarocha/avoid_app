import 'dart:async';

import 'package:avoid_app/ui/helpers/helpers.dart';
import 'package:avoid_app/ui/pages/login/login_page.dart';
import 'package:avoid_app/ui/pages/login/login_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class LoginPresenterSpy extends Mock implements LoginPresenter {}

late LoginPresenter presenter;
void initStreams() {
  emailErrorController = StreamController<UIError?>();
  passwordErrorController = StreamController<UIError?>();
  mainErrorController = StreamController<String>();
  navigateToController = StreamController<String>();

  isFormValidController = StreamController<bool>();
  isLoadingController = StreamController<bool>();
}

void mockStreams() {
  when(() => presenter.userNameErrorStream)
      .thenAnswer((_) => emailErrorController.stream);
  when(() => presenter.passwordErrorStream)
      .thenAnswer((_) => passwordErrorController.stream);
  when(() => presenter.mainErrorStream)
      .thenAnswer((_) => mainErrorController.stream);
  when(() => presenter.navigateToStream)
      .thenAnswer((_) => navigateToController.stream);
  when(() => presenter.isFormValidStream)
      .thenAnswer((_) => isFormValidController.stream);
  when(() => presenter.isLoadingStream)
      .thenAnswer((_) => isLoadingController.stream);
}

void closeStreams() {
  emailErrorController.close();
  passwordErrorController.close();
  mainErrorController.close();
  navigateToController.close();
  isFormValidController.close();
  isLoadingController.close();
}

late StreamController<UIError?> emailErrorController;
late StreamController<UIError?> passwordErrorController;
late StreamController<String> mainErrorController;
late StreamController<String> navigateToController;

late StreamController<bool> isFormValidController;
late StreamController<bool> isLoadingController;
void main() {
  setUp(() {
    presenter = LoginPresenterSpy();
    initStreams();
    mockStreams();
  });
  Future<void> loadPage(WidgetTester tester) async {
    final loginPage = GetMaterialApp(
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage(presenter)),
        GetPage(
            name: '/any_route',
            page: () => const Scaffold(body: Text('fake page'))),
      ],
    );
    await tester.pumpWidget(loginPage);
  }

  testWidgets('Should load with corret initial state', (tester) async {
    await loadPage(tester);

    final userNameTextChildren = find.descendant(
        of: find.bySemanticsLabel('User Name'), matching: find.byType(Text));
    expect(userNameTextChildren, findsOneWidget,
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
