import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String reviewerImageUrl;
  final double rating;
  final String comment;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImageUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      reviewerId: map['reviewer_id'] ?? '',
      reviewerName: map['reviewer_name'] ?? 'Anonymous',
      reviewerImageUrl: map['reviewer_image'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        reviewerId,
        reviewerName,
        reviewerImageUrl,
        rating,
        comment,
        timestamp,
      ];
}
