import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy danh sách sản phẩm với filter
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) async {
    return await repository.getProducts(
      category: category,
      brand: brand,
      isActive: isActive ?? true,
      isFeatured: isFeatured,
      limit: limit,
    );
  }
}
