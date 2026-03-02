import 'package:equatable/equatable.dart';

enum BacklogType { movie, series, song, book, game, hobby }
enum BacklogStatus { completed, inProgress, planned }

class BacklogItem extends Equatable {
  final String id;
  final String title;
  final BacklogType type;
  final BacklogStatus status;
  final double? rating; // 0-5
  final DateTime? dateCompleted;
  final String? review;
  final String? imageUrl;
  final DateTime createdAt;

  const BacklogItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    this.rating,
    this.dateCompleted,
    this.review,
    this.imageUrl,
  });

  BacklogItem copyWith({
    String? id,
    String? title,
    BacklogType? type,
    BacklogStatus? status,
    double? rating,
    DateTime? dateCompleted,
    String? review,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return BacklogItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      review: review ?? this.review,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name, // e.g. "movie"
      'status': status.name, // e.g. "completed"
      'rating': rating,
      'dateCompleted': dateCompleted?.toIso8601String(),
      'review': review,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BacklogItem.fromJson(Map<String, dynamic> json) {
    return BacklogItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: BacklogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BacklogType.hobby,
      ),
      status: BacklogStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BacklogStatus.planned,
      ),
      rating: (json['rating'] as num?)?.toDouble(),
      dateCompleted: json['dateCompleted'] != null
          ? DateTime.parse(json['dateCompleted'] as String)
          : null,
      review: json['review'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        status,
        rating,
        dateCompleted,
        review,
        imageUrl,
        createdAt,
      ];
}
