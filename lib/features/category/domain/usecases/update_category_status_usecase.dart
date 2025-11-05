import '../repositories/category_repository.dart';

class UpdateCategoryStatusUseCase {
  final CategoryRepository _repository;

  UpdateCategoryStatusUseCase(this._repository);

  Future<void> call(UpdateCategoryStatusParams params) async {
    if (params.categoryId.isEmpty) {
      throw ArgumentError('Category ID không được rỗng');
    }
    final category = await _repository.getCategoryById(params.categoryId);
    if (category == null) {
      throw Exception('Danh mục không tồn tại');
    }

    return await _repository.updateCategoryStatus(
      params.categoryId,
      params.isActive,
    );
  }
}

/// Parameters cho UpdateCategoryStatusUseCase
class UpdateCategoryStatusParams {
  final String categoryId;
  final bool isActive;

  const UpdateCategoryStatusParams({
    required this.categoryId,
    required this.isActive,
  });
}
