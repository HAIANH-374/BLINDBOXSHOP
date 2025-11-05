import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

/// UseCase: Lấy giỏ hàng của user
class GetUserCartUseCase {
  final CartRepository repository;

  GetUserCartUseCase(this.repository);

  Future<CartEntity?> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.getUserCart(userId);
  }
}
