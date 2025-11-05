import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy sản phẩm theo danh mục
class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call(String category, {int? limit}) async {
    if (category.trim().isEmpty) {
      throw ArgumentError('Danh mục không được để trống');
    }

    return await repository.getProductsByCategory(
      category.trim(),
      limit: limit,
    );
  }
}
