import '../repositories/review_repository.dart';

/// UseCase: Kiểm tra user đã đánh giá sản phẩm chưa
class HasUserReviewedUseCase {
  final ReviewRepository repository;

  HasUserReviewedUseCase(this.repository);

  Future<bool> call(String productId, String userId) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.hasUserReviewed(productId, userId);
  }
}
