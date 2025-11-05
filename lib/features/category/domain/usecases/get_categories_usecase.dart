import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để lấy danh sách danh mục
///
/// UseCase này cho phép lấy danh mục với các tùy chọn lọc và sắp xếp.
///
/// Input: GetCategoriesParams
/// Output: List<CategoryEntity>
class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [params] - Parameters chứa các tùy chọn lọc
  ///
  /// Trả về: Danh sách CategoryEntity
  /// Throws: Exception nếu có lỗi
  Future<List<CategoryEntity>> call(GetCategoriesParams params) async {
    // Validation
    if (params.limit != null && params.limit! <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return await _repository.getCategories(
      isActive: params.isActive,
      limit: params.limit,
      orderBy: params.orderBy,
      descending: params.descending,
    );
  }
}

/// Parameters cho GetCategoriesUseCase
class GetCategoriesParams {
  final bool? isActive;
  final int? limit;
  final String? orderBy;
  final bool descending;

  const GetCategoriesParams({
    this.isActive,
    this.limit,
    this.orderBy,
    this.descending = false,
  });
}
