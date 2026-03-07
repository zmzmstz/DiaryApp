import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/backlog_item.dart';
import '../../models/search_result.dart';

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';

  String get _apiKey => dotenv.env['RAWG_API_KEY'] ?? '';

  Future<List<SearchResult>> searchGames(String query) async {
    if (_apiKey.isEmpty || query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl/games?key=$_apiKey&search=${Uri.encodeComponent(query)}&page_size=15',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      return results.map((item) => _mapToSearchResult(item)).toList();
    } catch (e) {
      print('RAWG search error: $e');
      return [];
    }
  }

  SearchResult _mapToSearchResult(Map<String, dynamic> item) {
    return SearchResult(
      externalId: 'rawg_${item['id']}',
      title: item['name'] ?? 'Unknown',
      overview: null,
      imageUrl: item['background_image'] as String?,
      releaseDate: item['released'] as String?,
      rating: (item['rating'] as num?)?.toDouble(),
      type: BacklogType.game,
      source: 'rawg',
    );
  }
}
