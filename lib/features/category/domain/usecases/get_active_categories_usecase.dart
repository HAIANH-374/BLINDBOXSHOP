import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để lấy danh sách danh mục đang hoạt động
///
/// UseCase đơn giản để lấy tất cả các danh mục có trạng thái active.
///
/// Input: int? limit (optional)
/// Output: List<CategoryEntity>
class GetActiveCategoriesUseCase {
  final CategoryRepository _repository;

  GetActiveCategoriesUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [limit] - Giới hạn số lượng kết quả (optional)
  ///
  /// Trả về: Danh sách CategoryEntity đang hoạt động
  /// Throws: Exception nếu có lỗi
  Future<List<CategoryEntity>> call({int? limit}) async {
    // Validation
    if (limit != null && limit <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return await _repository.getActiveCategories(limit: limit);
  }
}
