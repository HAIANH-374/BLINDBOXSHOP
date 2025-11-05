import '../repositories/review_repository.dart';

/// UseCase: Đánh dấu đánh giá hữu ích
class MarkHelpfulUseCase {
  final ReviewRepository repository;

  MarkHelpfulUseCase(this.repository);

  Future<void> call(String reviewId, String userId) async {
    if (reviewId.isEmpty) {
      throw ArgumentError('Review ID không được để trống');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.markHelpful(reviewId, userId);
  }
}
