import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Lấy danh sách đơn hàng của user
class GetUserOrdersUseCase {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.getUserOrders(userId);
  }
}
