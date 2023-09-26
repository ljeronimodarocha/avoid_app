import 'package:avoid_app/ui/helpers/i18n/strings/en_us.dart';
import 'package:flutter/widgets.dart';

import './strings/strings.dart';

class R {
  static Translation string = PtBr();

  static void load(Locale locale) {
    switch (locale.toString()) {
      case 'en':
        string = EnUs();
        break;
      default:
        string = PtBr();
        break;
    }
  }
}
