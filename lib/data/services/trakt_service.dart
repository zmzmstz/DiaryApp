import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/backlog_item.dart';
import '../../models/search_result.dart';

class TraktService {
  static const String _baseUrl = 'https://api.trakt.tv';

  String get _clientId => dotenv.env['TRAKT_CLIENT_ID'] ?? '';

  /// Trakt.tv returns metadata only (no images).
  /// Use together with TMDB to fetch poster images via the included TMDB ID.
  Future<List<SearchResult>> searchAll(String query) async {
    if (_clientId.isEmpty || query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl/search/movie,show?query=${Uri.encodeComponent(query)}&limit=15&extended=full',
    );

    try {
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': _clientId,
      });

      if (response.statusCode != 200) return [];

      final List results = json.decode(response.body);
      return results.map((item) => _mapToSearchResult(item)).toList();
    } catch (e) {
      print('Trakt search error: $e');
      return [];
    }
  }

  SearchResult _mapToSearchResult(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final media = item[type] as Map<String, dynamic>;
    final ids = media['ids'] as Map<String, dynamic>?;
    final tmdbId = ids?['tmdb'];

    final isMovie = type == 'movie';

    return SearchResult(
      externalId: 'trakt_${ids?['trakt'] ?? media['title']}',
      title: media['title'] ?? 'Unknown',
      overview: media['overview'] as String?,
      imageUrl: tmdbId != null
          ? 'https://image.tmdb.org/t/p/w500' // placeholder, resolved later
          : null,
      releaseDate: isMovie
          ? media['released'] as String?
          : media['first_aired'] as String?,
      rating: (media['rating'] as num?)?.toDouble(),
      type: isMovie ? BacklogType.movie : BacklogType.series,
      source: 'trakt',
    );
  }
}
