import '../repositories/cart_repository.dart';

/// UseCase: Xóa toàn bộ giỏ hàng
class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<bool> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.clearCart(userId);
  }
}
