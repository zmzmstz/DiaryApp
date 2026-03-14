import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/backend_config.dart';
import '../../models/search_result.dart';
import '../../models/backlog_item.dart';
import 'backlog_repository.dart';

class ApiRepository {
  final BacklogRepository _backlogRepository;

  ApiRepository({
    required BacklogRepository backlogRepository,
  }) : _backlogRepository = backlogRepository;

  String get _baseUrl => BackendConfig.apiBaseUrl;

  BacklogType _parseType(String? rawType) {
    if (rawType == null) return BacklogType.hobby;
    return BacklogType.values.firstWhere(
      (type) => type.name == rawType,
      orElse: () => BacklogType.hobby,
    );
  }

  SearchResult _fromJson(Map<String, dynamic> json) {
    return SearchResult(
      externalId: json['externalId'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      overview: json['overview'] as String?,
      imageUrl: json['imageUrl'] as String?,
      releaseDate: json['releaseDate'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      type: _parseType(json['type'] as String?),
      source: json['source'] as String? ?? 'unknown',
    );
  }

  /// Search across all APIs concurrently and merge results.
  /// Backend proxies TMDB, RAWG, Trakt, Spotify and Open Library so API keys stay off mobile.
  Future<List<SearchResult>> searchAll(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final token = _backlogRepository.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search?q=${Uri.encodeQueryComponent(cleanQuery)}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Search failed with status ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(_fromJson)
        .toList();
  }

  Future<List<SearchResult>> searchMoviesAndSeries(String query) async {
    final all = await searchAll(query);
    return all
        .where((item) => item.type == BacklogType.movie || item.type == BacklogType.series)
        .toList();
  }

  Future<List<SearchResult>> searchGames(String query) async {
    final all = await searchAll(query);
    return all.where((item) => item.type == BacklogType.game).toList();
  }
}
