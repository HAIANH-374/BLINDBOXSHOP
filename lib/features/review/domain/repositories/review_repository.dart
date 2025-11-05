import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  });

  Future<ReviewEntity?> getReviewById(String reviewId);

  Future<List<ReviewEntity>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  });

  Future<List<ReviewEntity>> getUserReviews(String userId);

  Future<List<ReviewEntity>> getPendingReviews();

  Future<ReviewStatsEntity> getReviewStats(String productId);

  Future<List<ReviewEntity>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  });

  Future<List<ReviewEntity>> getVerifiedReviews(String productId, {int? limit});

  Future<List<ReviewEntity>> getReviewsWithImages(
    String productId, {
    int? limit,
  });

  Future<List<ReviewEntity>> searchReviews(String query);

  // Các thao tác lệnh
  Future<ReviewEntity> createReview(ReviewEntity review);

  Future<void> updateReview(ReviewEntity review);

  Future<void> deleteReview(String reviewId);

  Future<void> approveReview(String reviewId);

  Future<void> rejectReview(String reviewId);

  Future<void> markHelpful(String reviewId, String userId);

  Future<void> unmarkHelpful(String reviewId, String userId);

  // Các thao tác kiểm tra
  Future<bool> hasUserReviewed(String productId, String userId);

  Future<ReviewEntity?> getUserReviewForProduct(
    String productId,
    String userId,
  );

  // Stream real-time
  Stream<ReviewEntity?> watchReview(String reviewId);

  Stream<List<ReviewEntity>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  });

  Stream<List<ReviewEntity>> watchUserReviews(String userId);

  Stream<List<ReviewEntity>> watchPendingReviews();
}
