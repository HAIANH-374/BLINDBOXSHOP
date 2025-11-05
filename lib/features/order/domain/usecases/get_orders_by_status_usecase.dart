import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Lấy đơn hàng theo trạng thái
class GetOrdersByStatusUseCase {
  final OrderRepository repository;

  GetOrdersByStatusUseCase(this.repository);

  Future<List<OrderEntity>> call(String userId, OrderStatus status) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.getOrdersByStatus(userId, status);
  }
}
