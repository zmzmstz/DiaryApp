import 'backlog_item.dart';

class SearchResult {
  final String externalId;
  final String title;
  final String? overview;
  final String? imageUrl;
  final String? releaseDate;
  final double? rating;
  final BacklogType type;
  final String source; // "tmdb", "rawg", "trakt"

  const SearchResult({
    required this.externalId,
    required this.title,
    required this.type,
    required this.source,
    this.overview,
    this.imageUrl,
    this.releaseDate,
    this.rating,
  });
}
