import '../repositories/review_repository.dart';

/// UseCase: Duyệt đánh giá (Admin)
class ApproveReviewUseCase {
  final ReviewRepository repository;

  ApproveReviewUseCase(this.repository);

  Future<void> call(String reviewId) async {
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID không được để trống');
    }

    return await repository.approveReview(reviewId);
  }
}
