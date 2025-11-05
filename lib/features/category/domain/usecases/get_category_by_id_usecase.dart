import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để lấy danh mục theo ID
///
/// UseCase này lấy thông tin chi tiết của một danh mục cụ thể.
///
/// Input: String categoryId
/// Output: CategoryEntity?
class GetCategoryByIdUseCase {
  final CategoryRepository _repository;

  GetCategoryByIdUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [categoryId] - ID của danh mục
  ///
  /// Trả về: CategoryEntity hoặc null nếu không tìm thấy
  /// Throws: Exception nếu có lỗi hoặc categoryId không hợp lệ
  Future<CategoryEntity?> call(String categoryId) async {
    // Validation
    if (categoryId.isEmpty) {
      throw ArgumentError('Category ID không được rỗng');
    }

    return await _repository.getCategoryById(categoryId);
  }
}
