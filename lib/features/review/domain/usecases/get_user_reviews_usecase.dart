import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

/// UseCase: Lấy danh sách đánh giá của user
class GetUserReviewsUseCase {
  final ReviewRepository repository;

  GetUserReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.getUserReviews(userId);
  }
}
