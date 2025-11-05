import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// UseCase để lắng nghe danh sách danh mục real-time
///
/// UseCase này tạo stream để theo dõi thay đổi danh mục real-time.
///
/// Input: WatchCategoriesParams
/// Output: Stream<List<CategoryEntity>>
class WatchCategoriesUseCase {
  final CategoryRepository _repository;

  WatchCategoriesUseCase(this._repository);

  /// Thực thi UseCase
  ///
  /// [params] - Parameters chứa các tùy chọn lọc
  ///
  /// Trả về: Stream danh sách CategoryEntity
  Stream<List<CategoryEntity>> call(WatchCategoriesParams params) {
    // Validation
    if (params.limit != null && params.limit! <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return _repository.watchCategories(
      isActive: params.isActive,
      limit: params.limit,
    );
  }
}

/// Parameters cho WatchCategoriesUseCase
class WatchCategoriesParams {
  final bool? isActive;
  final int? limit;

  const WatchCategoriesParams({this.isActive, this.limit});
}
