import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để tìm kiếm danh mục
///
/// UseCase này tìm kiếm danh mục theo từ khóa trong tên và mô tả.
///
/// Input: String query
/// Output: List<CategoryEntity>
class SearchCategoriesUseCase {
  final CategoryRepository _repository;

  SearchCategoriesUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [query] - Từ khóa tìm kiếm
  ///
  /// Trả về: Danh sách CategoryEntity phù hợp với từ khóa
  /// Throws: Exception nếu có lỗi
  Future<List<CategoryEntity>> call(String query) async {
    // Validation - Cho phép query rỗng (trả về tất cả)
    final trimmedQuery = query.trim();

    return await _repository.searchCategories(trimmedQuery);
  }
}
