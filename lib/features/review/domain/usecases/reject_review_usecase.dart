import '../repositories/review_repository.dart';

/// UseCase: Từ chối đánh giá (Admin)
class RejectReviewUseCase {
  final ReviewRepository repository;

  RejectReviewUseCase(this.repository);

  Future<void> call(String reviewId) async {
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID không được để trống');
    }

    return await repository.rejectReview(reviewId);
  }
}
