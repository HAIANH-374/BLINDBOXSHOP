import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Lấy danh sách đánh giá theo sản phẩm
class GetReviewsByProductUseCase {
  final ReviewRepository repository;

  GetReviewsByProductUseCase(this.repository);

  Future<List<ReviewEntity>> call(
    String productId, {
    ReviewStatus? status,
    int? limit,
    String? sortBy,
  }) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.getReviewsByProduct(
      productId,
      status: status,
      limit: limit,
      sortBy: sortBy,
    );
  }
}
