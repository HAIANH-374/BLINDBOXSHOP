import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Cập nhật đánh giá
class UpdateReviewUseCase {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  Future<void> call(ReviewEntity review) async {
    // Kiểm tra dữ liệu
    if (review.id.isEmpty) {
      throw ArgumentError('Review ID không được để trống');
    }

    if (review.rating < 1 || review.rating > 5) {
      throw ArgumentError('Rating phải từ 1 đến 5');
    }

    if (review.comment.trim().isEmpty) {
      throw ArgumentError('Nội dung đánh giá không được để trống');
    }

    if (review.comment.trim().length < 10) {
      throw ArgumentError('Nội dung đánh giá phải có ít nhất 10 ký tự');
    }

    return await repository.updateReview(review);
  }
}
