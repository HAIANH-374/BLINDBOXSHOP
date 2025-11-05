import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy danh sách sản phẩm hot/trending
class GetHotProductsUseCase {
  final ProductRepository repository;

  GetHotProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getHotProducts();
  }
}
