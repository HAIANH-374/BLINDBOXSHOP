import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để lấy thống kê về danh mục
///
/// UseCase này lấy thống kê tổng quan về tất cả danh mục trong hệ thống.
///
/// Input: void
/// Output: CategoryStatsEntity
class GetCategoryStatsUseCase {
  final CategoryRepository _repository;

  GetCategoryStatsUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// Trả về: CategoryStatsEntity chứa thống kê
  /// Throws: Exception nếu có lỗi
  Future<CategoryStatsEntity> call() async {
    return await _repository.getCategoryStats();
  }
}
