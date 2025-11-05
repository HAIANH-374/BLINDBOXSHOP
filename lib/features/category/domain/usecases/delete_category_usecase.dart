import '../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<void> call(String categoryId) async {
    if (categoryId.isEmpty) {
      throw ArgumentError('Category ID không được rỗng');
    }
    final category = await _repository.getCategoryById(categoryId);
    if (category == null) {
      throw Exception('Danh mục không tồn tại');
    }

    return await _repository.deleteCategory(categoryId);
  }
}
