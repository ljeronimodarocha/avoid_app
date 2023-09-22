import 'package:avoid_app/domain/usecases/load_movies.dart';

import '../../../data/usecases/usecases.dart';
import '../factories.dart';

LoadMovies makeLoadMovies() {
  return RemoteLoadMovies(
      makeHttpAdapter(), makeApiUrl('filme'), makeLocalLoadCurrentAccount());
}
