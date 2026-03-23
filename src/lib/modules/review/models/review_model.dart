class ReviewModel {
  final int id;
  final int reservationId;
  final String reviewerId;
  final int spotId;
  final int rating;
  final String? comment;
  final String? ownerReply;
  final DateTime? ownerRepliedAt;
  final bool isVisible;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reservationId,
    required this.reviewerId,
    required this.spotId,
    required this.rating,
    this.comment,
    this.ownerReply,
    this.ownerRepliedAt,
    required this.isVisible,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      reservationId: json['reservation_id'] as int,
      reviewerId: json['reviewer_id'] as String,
      spotId: json['spot_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      ownerReply: json['owner_reply'] as String?,
      ownerRepliedAt: json['owner_replied_at'] != null
          ? DateTime.parse(json['owner_replied_at'] as String)
          : null,
      isVisible: json['is_visible'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'reviewer_id': reviewerId,
      'spot_id': spotId,
      'rating': rating,
      'comment': comment,
      'owner_reply': ownerReply,
      'owner_replied_at': ownerRepliedAt?.toIso8601String(),
      'is_visible': isVisible,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
