import 'package:avoid_app/main/factories/factories.dart';
import 'package:avoid_app/main/factories/usescases/add_account_factory.dart';
import 'package:avoid_app/presentation/presenters/getx_signup_presenter.dart';

import 'signup_validation_factory.dart';

GetxSignUpPresenter makeGetXSignUpPresenter() {
  return GetxSignUpPresenter(
      validation: makeSignUpValidation(),
      addAccount: makeRemoteAddAccount(),
      saveCurrentAccount: makeSaveCurrentAccount());
}
