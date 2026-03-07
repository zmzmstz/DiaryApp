import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/backlog_item.dart';
import '../../models/search_result.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  Future<List<SearchResult>> searchMulti(String query) async {
    if (_apiKey.isEmpty || query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&language=tr-TR&page=1',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      return results
          .where((item) =>
              item['media_type'] == 'movie' || item['media_type'] == 'tv')
          .map((item) => _mapToSearchResult(item))
          .toList();
    } catch (e) {
      print('TMDB search error: $e');
      return [];
    }
  }

  SearchResult _mapToSearchResult(Map<String, dynamic> item) {
    final isMovie = item['media_type'] == 'movie';
    final posterPath = item['poster_path'] as String?;

    return SearchResult(
      externalId: 'tmdb_${item['id']}',
      title: (isMovie ? item['title'] : item['name']) ?? 'Unknown',
      overview: item['overview'] as String?,
      imageUrl: posterPath != null ? '$_imageBaseUrl$posterPath' : null,
      releaseDate: isMovie
          ? item['release_date'] as String?
          : item['first_air_date'] as String?,
      rating: (item['vote_average'] as num?)?.toDouble(),
      type: isMovie ? BacklogType.movie : BacklogType.series,
      source: 'tmdb',
    );
  }

  /// Fetch poster URL for a specific TMDB ID (movie or tv)
  Future<String?> getPosterUrl(int tmdbId, {bool isMovie = true}) async {
    if (_apiKey.isEmpty) return null;

    final type = isMovie ? 'movie' : 'tv';
    final uri = Uri.parse('$_baseUrl/$type/$tmdbId?api_key=$_apiKey');

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final posterPath = data['poster_path'] as String?;
      return posterPath != null ? '$_imageBaseUrl$posterPath' : null;
    } catch (e) {
      return null;
    }
  }
}
