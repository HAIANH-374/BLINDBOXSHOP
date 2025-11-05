import '../repositories/cart_repository.dart';

/// UseCase: Cập nhật số lượng sản phẩm trong giỏ
class UpdateItemQuantityUseCase {
  final CartRepository repository;

  UpdateItemQuantityUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String productId,
    required int quantity,
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

    return await repository.updateItemQuantity(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
  }
}
