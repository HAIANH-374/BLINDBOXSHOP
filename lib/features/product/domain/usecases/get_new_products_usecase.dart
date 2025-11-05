import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy danh sách sản phẩm mới
class GetNewProductsUseCase {
  final ProductRepository repository;

  GetNewProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getNewProducts();
  }
}
