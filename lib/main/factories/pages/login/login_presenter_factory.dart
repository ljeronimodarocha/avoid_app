import '../../../../presentation/presentation.dart';
import '../../../factories/factories.dart';

StreamLoginPresenter makeStreamLoginPresenter() {
  return StreamLoginPresenter(
      validation: makeValidationComposite(),
      authentication: makeRemoteAuthentication());
}

GetXLoginPresenter makeGetXLoginPresenter() {
  return GetXLoginPresenter(
    validation: makeValidationComposite(),
    authentication: makeRemoteAuthentication(),
    saveCurrentAccount: makeSaveCurrentAccount(),
  );
}
