import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Tìm kiếm sản phẩm
class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Từ khóa tìm kiếm không được để trống');
    }

    return await repository.searchProducts(
      query.trim(),
      category: category,
      brand: brand,
      limit: limit,
    );
  }
}
