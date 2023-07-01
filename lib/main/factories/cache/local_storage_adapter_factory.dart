import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../infra/infra.dart';

LocalStorageAdapter makeLocalStorageAdapter() {
  const secureStorage = FlutterSecureStorage();
  return LocalStorageAdapter(secureStorage: secureStorage);
}
