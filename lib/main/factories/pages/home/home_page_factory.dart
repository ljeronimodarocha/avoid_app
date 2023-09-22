import 'package:avoid_app/views/home_screen.dart';
import 'package:flutter/widgets.dart';

import 'home_presenter_factory.dart';

Widget makeHomePage() {
  return HomeScreen(false, makeGetXLoginPresenter());
}
