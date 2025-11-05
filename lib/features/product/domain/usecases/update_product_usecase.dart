import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// UseCase: Cập nhật sản phẩm (Admin)
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) async {
    // Xác thực dữ liệu sản phẩm
    if (product.id.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }
    if (product.name.isEmpty) {
      throw ArgumentError('Tên sản phẩm không được để trống');
    }
    if (product.price <= 0) {
      throw ArgumentError('Giá sản phẩm phải lớn hơn 0');
    }
    if (product.category.isEmpty) {
      throw ArgumentError('Danh mục sản phẩm không được để trống');
    }

    return await repository.updateProduct(product);
  }
}
