import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository _repository;

  CreateCategoryUseCase(this._repository);

  Future<CategoryEntity> call(CategoryEntity category) async {
    if (!category.hasValidName) {
      throw ArgumentError(
        'Tên danh mục không hợp lệ. Phải có ít nhất 2 ký tự.',
      );
    }

    if (!category.hasValidOrder) {
      throw ArgumentError('Thứ tự danh mục phải lớn hơn hoặc bằng 0');
    }

    final exists = await _repository.categoryExists(category.name);
    if (exists) {
      throw Exception('Danh mục "${category.name}" đã tồn tại');
    }

    return await _repository.createCategory(category);
  }
}
