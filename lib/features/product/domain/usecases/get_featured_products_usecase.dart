import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy danh sách sản phẩm nổi bật
class GetFeaturedProductsUseCase {
  final ProductRepository repository;

  GetFeaturedProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getFeaturedProducts();
  }
}
