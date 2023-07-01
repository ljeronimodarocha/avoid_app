import '../../../../presentation/presentation.dart';
import '../../../../ui/pages/pages.dart';
import '../../usescases/usescases.dart';

SplashPresenter makeGetXSplashPresenter() {
  return GetxSplashPresenter(loadCurrentAccount: makeLocalLoadCurrentAccount());
}
