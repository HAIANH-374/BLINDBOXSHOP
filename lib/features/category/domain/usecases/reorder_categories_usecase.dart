import '../repositories/category_repository.dart';

/// UseCase để sắp xếp lại thứ tự danh mục
///
/// UseCase này cập nhật thứ tự của nhiều danh mục cùng lúc.
///
/// Input: List<String> categoryIds
/// Output: void
class ReorderCategoriesUseCase {
  final CategoryRepository _repository;

  ReorderCategoriesUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [categoryIds] - Danh sách ID danh mục theo thứ tự mới
  ///
  /// Trả về: void
  /// Throws: Exception nếu có lỗi hoặc dữ liệu không hợp lệ
  Future<void> call(List<String> categoryIds) async {
    // Validation
    if (categoryIds.isEmpty) {
      throw ArgumentError('Danh sách categoryIds không được rỗng');
    }

    // Kiểm tra có ID trùng lặp không
    final uniqueIds = categoryIds.toSet();
    if (uniqueIds.length != categoryIds.length) {
      throw ArgumentError('Danh sách categoryIds có ID trùng lặp');
    }

    // Kiểm tra tất cả ID có hợp lệ không
    for (final id in categoryIds) {
      if (id.isEmpty) {
        throw ArgumentError('Category ID không được rỗng');
      }
    }

    return await _repository.reorderCategories(categoryIds);
  }
}
