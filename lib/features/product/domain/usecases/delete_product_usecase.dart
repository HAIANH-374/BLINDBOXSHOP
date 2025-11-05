import '../repositories/product_repository.dart';

/// UseCase: Xóa sản phẩm (Admin)
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(String productId) async {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.deleteProduct(productId);
  }
}
