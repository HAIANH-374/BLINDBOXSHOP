import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Tạo đánh giá mới
class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<ReviewEntity> call(ReviewEntity review) async {
    // Kiểm tra nghiệp vụ
    if (review.rating < 1 || review.rating > 5) {
      throw ArgumentError('Rating phải từ 1 đến 5');
    }

    if (review.comment.trim().isEmpty) {
      throw ArgumentError('Nội dung đánh giá không được để trống');
    }

    if (review.comment.trim().length < 10) {
      throw ArgumentError('Nội dung đánh giá phải có ít nhất 10 ký tự');
    }

    if (review.userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    if (review.productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.createReview(review);
  }
}
