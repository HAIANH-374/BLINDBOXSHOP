import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Lấy danh sách đánh giá chờ duyệt
class GetPendingReviewsUseCase {
  final ReviewRepository repository;

  GetPendingReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call() async {
    return await repository.getPendingReviews();
  }
}
