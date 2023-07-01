import 'package:avoid_app/ui/pages/login/login_page.dart';
import 'package:flutter/material.dart';

import '../../factories.dart';

Widget makeLoginPage() {
  return LoginPage(makeGetXLoginPresenter());
}
