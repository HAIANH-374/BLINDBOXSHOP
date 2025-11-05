import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Lấy đơn hàng theo ID
class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<OrderEntity?> call(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.getOrderById(orderId);
  }
}
