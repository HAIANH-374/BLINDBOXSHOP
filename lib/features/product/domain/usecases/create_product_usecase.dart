import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<ProductEntity> call(ProductEntity product) async {
    if (product.name.isEmpty) {
      throw ArgumentError('Tên sản phẩm không được để trống');
    }
    if (product.price <= 0) {
      throw ArgumentError('Giá sản phẩm phải lớn hơn 0');
    }
    if (product.category.isEmpty) {
      throw ArgumentError('Danh mục sản phẩm không được để trống');
    }

    return await repository.createProduct(product);
  }
}
