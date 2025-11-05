import '../repositories/cart_repository.dart';

/// UseCase: Xóa sản phẩm khỏi giỏ hàng
class RemoveItemFromCartUseCase {
  final CartRepository repository;

  RemoveItemFromCartUseCase(this.repository);

  Future<bool> call({required String userId, required String productId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    if (productId.isEmpty) {
      throw ArgumentError('Product ID không được để trống');
    }

    return await repository.removeItemFromCart(
      userId: userId,
      productId: productId,
    );
  }
}
