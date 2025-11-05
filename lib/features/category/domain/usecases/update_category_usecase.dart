import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<void> call(CategoryEntity category) async {
    if (category.id.isEmpty) {
      throw ArgumentError('Category ID không được rỗng');
    }

    if (!category.hasValidName) {
      throw ArgumentError(
        'Tên danh mục không hợp lệ. Phải có ít nhất 2 ký tự.',
      );
    }

    if (!category.hasValidOrder) {
      throw ArgumentError('Thứ tự danh mục phải lớn hơn hoặc bằng 0');
    }

    final existingCategory = await _repository.getCategoryById(category.id);
    if (existingCategory == null) {
      throw Exception('Danh mục không tồn tại');
    }

    final categoryByName = await _repository.getCategoryByName(category.name);
    if (categoryByName != null && categoryByName.id != category.id) {
      throw Exception('Tên danh mục "${category.name}" đã được sử dụng');
    }

    return await _repository.updateCategory(category);
  }
}
