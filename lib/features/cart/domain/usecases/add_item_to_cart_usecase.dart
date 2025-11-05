import '../repositories/cart_repository.dart';

/// UseCase: Thêm sản phẩm vào giỏ hàng
class AddItemToCartUseCase {
  final CartRepository repository;

  AddItemToCartUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    int quantity = 1,
    String productType = 'single',
    int? boxSize,
    int? setSize,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    if (quantity <= 0) {
      throw ArgumentError('Số lượng phải lớn hơn 0');
    }

    if (price < 0) {
      throw ArgumentError('Giá sản phẩm không hợp lệ');
    }

    return await repository.addItemToCart(
      userId: userId,
      productId: productId,
      productName: productName,
      price: price,
      productImage: productImage,
      quantity: quantity,
      productType: productType,
      boxSize: boxSize,
      setSize: setSize,
    );
  }
}
