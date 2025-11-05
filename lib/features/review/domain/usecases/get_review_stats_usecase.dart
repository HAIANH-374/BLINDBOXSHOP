import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Lấy thống kê đánh giá của sản phẩm
class GetReviewStatsUseCase {
  final ReviewRepository repository;

  GetReviewStatsUseCase(this.repository);

  Future<ReviewStatsEntity> call(String productId) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.getReviewStats(productId);
  }
}
