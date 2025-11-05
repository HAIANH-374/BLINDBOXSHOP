/// Enum trạng thái Review
enum ReviewStatus {
  pending, // Chờ duyệt
  approved, // Đã duyệt
  rejected, // Từ chối
}

class ReviewEntity {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int rating; // 1-5 stars
  final String comment;
  final List<String> images;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified; // Đã mua sản phẩm
  final String? orderId; // ID đơn hàng để xác minh
  final int helpfulCount; // Số lượt hữu ích
  final List<String> helpfulUsers; // Danh sách user đã vote hữu ích

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    this.orderId,
    required this.helpfulCount,
    required this.helpfulUsers,
  });

  /// Kiểm tra đánh giá có hình ảnh không
  bool get hasImages => images.isNotEmpty;

  /// Kiểm tra rating cao (>= 4 sao)
  bool get isHighRating => rating >= 4;

  /// Kiểm tra rating trung bình (3 sao)
  bool get isMediumRating => rating == 3;

  /// Kiểm tra rating thấp (<= 2 sao)
  bool get isLowRating => rating <= 2;

  /// Kiểm tra đánh giá đã được duyệt
  bool get isApproved => status == ReviewStatus.approved;

  /// Kiểm tra đánh giá đang chờ duyệt
  bool get isPending => status == ReviewStatus.pending;

  /// Kiểm tra đánh giá bị từ chối
  bool get isRejected => status == ReviewStatus.rejected;

  /// Text mô tả rating
  String get ratingText {
    switch (rating) {
      case 5:
        return 'Tuyệt vời';
      case 4:
        return 'Hài lòng';
      case 3:
        return 'Bình thường';
      case 2:
        return 'Không hài lòng';
      case 1:
        return 'Rất tệ';
      default:
        return 'Không xác định';
    }
  }

  /// Text trạng thái
  String get statusText {
    switch (status) {
      case ReviewStatus.pending:
        return 'Chờ duyệt';
      case ReviewStatus.approved:
        return 'Đã duyệt';
      case ReviewStatus.rejected:
        return 'Từ chối';
    }
  }

  /// Định dạng thời gian tương đối
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Danh sách trạng thái sao (true = có sao, false = không có sao)
  List<bool> get starRatings {
    return List.generate(5, (index) => index < rating);
  }

  /// Kiểm tra user đã đánh dấu hữu ích chưa
  bool isHelpfulBy(String userId) => helpfulUsers.contains(userId);

  /// Kiểm tra đánh giá có nhiều người thấy hữu ích không
  bool get isPopular => helpfulCount >= 10;

  /// Kiểm tra đánh giá chi tiết (comment dài)
  bool get isDetailed => comment.length >= 100;

  /// Kiểm tra đánh giá đáng tin cậy (verified + có ảnh + chi tiết)
  bool get isTrustworthy => isVerified && hasImages && isDetailed;

  ReviewEntity copyWith({
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
    return ReviewEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Entity thống kê Review
class ReviewStatsEntity {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution; // {5: 100, 4: 50, 3: 20, 2: 5, 1: 2}
  final int verifiedReviews;
  final int withImages;

  const ReviewStatsEntity({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.verifiedReviews,
    required this.withImages,
  });

  /// Phần trăm rating 5 sao
  double get fiveStarPercentage =>
      totalReviews > 0 ? (ratingDistribution[5] ?? 0) / totalReviews * 100 : 0;

  /// Phần trăm rating 4 sao
  double get fourStarPercentage =>
      totalReviews > 0 ? (ratingDistribution[4] ?? 0) / totalReviews * 100 : 0;

  /// Phần trăm rating 3 sao
  double get threeStarPercentage =>
      totalReviews > 0 ? (ratingDistribution[3] ?? 0) / totalReviews * 100 : 0;

  /// Phần trăm rating 2 sao
  double get twoStarPercentage =>
      totalReviews > 0 ? (ratingDistribution[2] ?? 0) / totalReviews * 100 : 0;

  /// Phần trăm rating 1 sao
  double get oneStarPercentage =>
      totalReviews > 0 ? (ratingDistribution[1] ?? 0) / totalReviews * 100 : 0;

  /// Phần trăm đánh giá đã xác minh
  double get verifiedPercentage =>
      totalReviews > 0 ? verifiedReviews / totalReviews * 100 : 0;

  /// Phần trăm đánh giá có hình ảnh
  double get withImagesPercentage =>
      totalReviews > 0 ? withImages / totalReviews * 100 : 0;

  /// Kiểm tra rating tốt (>= 4.0)
  bool get hasGoodRating => averageRating >= 4.0;

  /// Kiểm tra có đủ đánh giá để tin cậy
  bool get hasEnoughReviews => totalReviews >= 10;

  /// Định dạng rating
  String get formattedRating => averageRating.toStringAsFixed(1);
}
