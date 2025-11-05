import '../repositories/review_repository.dart';

/// UseCase: Xóa đánh giá
class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<void> call(String reviewId) async {
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID không được để trống');
    }

    return await repository.deleteReview(reviewId);
  }
}
