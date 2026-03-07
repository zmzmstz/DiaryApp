import '../../models/search_result.dart';
import '../services/tmdb_service.dart';
import '../services/rawg_service.dart';
import '../services/trakt_service.dart';

class ApiRepository {
  final TmdbService _tmdbService;
  final RawgService _rawgService;
  final TraktService _traktService;

  ApiRepository({
    TmdbService? tmdbService,
    RawgService? rawgService,
    TraktService? traktService,
  })  : _tmdbService = tmdbService ?? TmdbService(),
        _rawgService = rawgService ?? RawgService(),
        _traktService = traktService ?? TraktService();

  /// Search across all APIs concurrently and merge results.
  /// TMDB covers movies/series, RAWG covers games, Trakt adds extra movie/series results.
  Future<List<SearchResult>> searchAll(String query) async {
    final results = await Future.wait([
      _tmdbService.searchMulti(query),
      _rawgService.searchGames(query),
      _traktService.searchAll(query),
    ]);

    final tmdbResults = results[0];
    final rawgResults = results[1];
    final traktResults = results[2];

    // Deduplicate: prefer TMDB over Trakt for same title
    final tmdbTitles = tmdbResults.map((r) => r.title.toLowerCase()).toSet();
    final uniqueTraktResults = traktResults
        .where((r) => !tmdbTitles.contains(r.title.toLowerCase()))
        .toList();

    return [...tmdbResults, ...rawgResults, ...uniqueTraktResults];
  }

  Future<List<SearchResult>> searchMoviesAndSeries(String query) {
    return _tmdbService.searchMulti(query);
  }

  Future<List<SearchResult>> searchGames(String query) {
    return _rawgService.searchGames(query);
  }
}
