import 'package:domain/domain.dart';

abstract interface class DataSource {
  Future<void> setSettings(Settings settings);
  
  Future<Settings?> getSettings();

  Future<void> updateMovies(
    String? baseImagePath,
    List<MovieInfo> movies, [
    DateTime? date,
  ]);

  Future<Movies?> getMoviesData({bool? refresh});
}
