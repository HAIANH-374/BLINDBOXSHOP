import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Lấy thông tin sản phẩm theo ID
class GetProductByIdUseCase {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<ProductEntity?> call(String productId) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.getProductById(productId);
  }
}
