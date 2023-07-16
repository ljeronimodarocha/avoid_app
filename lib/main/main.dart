import 'package:avoid_app/views/home_screen.dart';
import 'package:provider/provider.dart';

import '../ui/pages/pages.dart';
import '/main/factories/factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  final previousCheck = Provider.debugCheckInvalidValueType;
  Provider.debugCheckInvalidValueType = <T>(T value) {
    if (value is LoginPresenter) return;
    previousCheck!<T>(value);
  };
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return GetMaterialApp(
      title: "Avoid App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: makeSplashPage,
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: makeLoginPage,
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/video',
          page: () => Scaffold(
            appBar: AppBar(
              title: const Text('Vídeos'),
            ),
            body: const Text('Home'),
          ),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
