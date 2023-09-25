import 'package:avoid_app/ui/pages/home/home_page.dart';
import 'package:flutter/widgets.dart';

import 'home_presenter_factory.dart';

Widget makeHomePage() {
  return HomeScreen(false, makeGetXLoginPresenter());
}
