import 'package:avoid_app/main/factories/pages/signup/signup_presenter_factory.dart';
import 'package:avoid_app/ui/pages/signup/signup_page.dart';
import 'package:flutter/material.dart';

Widget makeSignUpPage() {
  return SignUpPage(makeGetXSignUpPresenter());
}
