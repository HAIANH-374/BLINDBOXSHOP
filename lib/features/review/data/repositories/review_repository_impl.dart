import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReviewEntity>> getReviews({
    String? productId,
    String? userId,
    ReviewStatus? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    final data = await remoteDataSource.getReviews(
      productId: productId,
      userId: userId,
      status: status?.name,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );

    return data
        .map((json) => ReviewModel.fromMap(json, json['id']))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<ReviewEntity?> getReviewById(String reviewId) async {
    final data = await remoteDataSource.getReviewById(reviewId);
    if (data == null) return null;

    final model = ReviewModel.fromMap(data, data['id']);
    return model.toEntity();
  }

  @override
  Future<List<ReviewEntity>> getReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  }) async {
    final data = await remoteDataSource.getReviewsByProduct(
      productId,
      status: status?.name,
      limit: limit,
      sortBy: sortBy,
    );

    return data
        .map((json) => ReviewModel.fromMap(json, json['id']))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ReviewEntity>> getUserReviews(String userId) async {
    final data = await remoteDataSource.getUserReviews(userId);

    return data
        .map((json) => ReviewModel.fromMap(json, json['id']))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ReviewEntity>> getPendingReviews() async {
    final data = await remoteDataSource.getPendingReviews();

    return data
        .map((json) => ReviewModel.fromMap(json, json['id']))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<ReviewStatsEntity> getReviewStats(String productId) async {
    final data = await remoteDataSource.getReviewStats(productId);
    final model = ReviewStatsModel.fromMap(data);
    return model.toEntity();
  }

  @override
  Future<List<ReviewEntity>> getReviewsByRating(
    String productId,
    int rating, {
    int? limit,
  }) async {
    final reviews = await getReviewsByProduct(
      productId,
      status: ReviewStatus.approved,
    );
    final filteredReviews = reviews.where((r) => r.rating == rating).toList();

    if (limit != null && limit > 0) {
      return filteredReviews.take(limit).toList();
    }

    return filteredReviews;
  }

  @override
  Future<List<ReviewEntity>> getVerifiedReviews(
    String productId, {
    int? limit,
  }) async {
    final reviews = await getReviewsByProduct(
      productId,
      status: ReviewStatus.approved,
    );
    final verifiedReviews = reviews.where((r) => r.isVerified).toList();

    if (limit != null && limit > 0) {
      return verifiedReviews.take(limit).toList();
    }

    return verifiedReviews;
  }

  @override
  Future<List<ReviewEntity>> getReviewsWithImages(
    String productId, {
    int? limit,
  }) async {
    final reviews = await getReviewsByProduct(
      productId,
      status: ReviewStatus.approved,
    );
    final reviewsWithImages = reviews.where((r) => r.hasImages).toList();

    if (limit != null && limit > 0) {
      return reviewsWithImages.take(limit).toList();
    }

    return reviewsWithImages;
  }

  @override
  Future<List<ReviewEntity>> searchReviews(String query) async {
    final data = await remoteDataSource.searchReviews(query);

    return data
        .map((json) => ReviewModel.fromMap(json, json['id']))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<ReviewEntity> createReview(ReviewEntity review) async {
    final model = ReviewModel.fromEntity(review);
    final docId = await remoteDataSource.createReview(model.toFirestore());

    return review.copyWith(id: docId);
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
    final model = ReviewModel.fromEntity(review);
    await remoteDataSource.updateReview(review.id, model.toFirestore());
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await remoteDataSource.deleteReview(reviewId);
  }

  @override
  Future<void> approveReview(String reviewId) async {
    await remoteDataSource.approveReview(reviewId);
  }

  @override
  Future<void> rejectReview(String reviewId) async {
    await remoteDataSource.rejectReview(reviewId);
  }

  @override
  Future<void> markHelpful(String reviewId, String userId) async {
    await remoteDataSource.markHelpful(reviewId, userId);
  }

  @override
  Future<void> unmarkHelpful(String reviewId, String userId) async {
    await remoteDataSource.unmarkHelpful(reviewId, userId);
  }

  @override
  Future<bool> hasUserReviewed(String productId, String userId) async {
    final reviews = await getReviews(productId: productId, userId: userId);
    return reviews.isNotEmpty;
  }

  @override
  Future<ReviewEntity?> getUserReviewForProduct(
    String productId,
    String userId,
  ) async {
    final reviews = await getReviews(productId: productId, userId: userId);
    return reviews.isNotEmpty ? reviews.first : null;
  }

  @override
  Stream<ReviewEntity?> watchReview(String reviewId) {
    return remoteDataSource.watchReview(reviewId).map((data) {
      if (data == null) return null;
      final model = ReviewModel.fromMap(data, data['id']);
      return model.toEntity();
    });
  }

  @override
  Stream<List<ReviewEntity>> watchReviewsByProduct(
    String productId, {
    ReviewStatus? status,
    int? limit,
  }) {
    return remoteDataSource
        .watchReviewsByProduct(productId, status: status?.name, limit: limit)
        .map(
          (dataList) => dataList
              .map((json) => ReviewModel.fromMap(json, json['id']))
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<ReviewEntity>> watchUserReviews(String userId) {
    return remoteDataSource
        .watchUserReviews(userId)
        .map(
          (dataList) => dataList
              .map((json) => ReviewModel.fromMap(json, json['id']))
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<ReviewEntity>> watchPendingReviews() {
    return remoteDataSource.watchPendingReviews().map(
      (dataList) => dataList
          .map((json) => ReviewModel.fromMap(json, json['id']))
          .map((model) => model.toEntity())
          .toList(),
    );
  }
}
