import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    required super.rating,
    required super.comment,
    required super.images,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.isVerified,
    super.orderId,
    required super.helpfulCount,
    required super.helpfulUsers,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(data, doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data, [String? id]) {
    return ReviewModel(
      id: id ?? data['id'] ?? '',
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      rating: data['rating'] ?? 5,
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      orderId: data['orderId'],
      helpfulCount: data['helpfulCount'] ?? 0,
      helpfulUsers: List<String>.from(data['helpfulUsers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'orderId': orderId,
      'helpfulCount': helpfulCount,
      'helpfulUsers': helpfulUsers,
    };
  }

  /// Chuyển đổi sang Entity
  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      images: images,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVerified: isVerified,
      orderId: orderId,
      helpfulCount: helpfulCount,
      helpfulUsers: helpfulUsers,
    );
  }

  /// Tạo Model từ Entity
  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      images: entity.images,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isVerified: entity.isVerified,
      orderId: entity.orderId,
      helpfulCount: entity.helpfulCount,
      helpfulUsers: entity.helpfulUsers,
    );
  }

  @override
  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? comment,
    List<String>? images,
    ReviewStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? orderId,
    int? helpfulCount,
    List<String>? helpfulUsers,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      orderId: orderId ?? this.orderId,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
    );
  }
}

/// Model thống kê Review
class ReviewStatsModel extends ReviewStatsEntity {
  const ReviewStatsModel({
    required super.totalReviews,
    required super.averageRating,
    required super.ratingDistribution,
    required super.verifiedReviews,
    required super.withImages,
  });

  factory ReviewStatsModel.fromMap(Map<String, dynamic> data) {
    return ReviewStatsModel(
      totalReviews: data['totalReviews'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingDistribution: Map<int, int>.from(
        data['ratingDistribution'] ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      ),
      verifiedReviews: data['verifiedReviews'] ?? 0,
      withImages: data['withImages'] ?? 0,
    );
  }

  ReviewStatsEntity toEntity() {
    return ReviewStatsEntity(
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
      verifiedReviews: verifiedReviews,
      withImages: withImages,
    );
  }
}
