import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Lấy đơn hàng theo số đơn hàng
class GetOrderByNumberUseCase {
  final OrderRepository repository;

  GetOrderByNumberUseCase(this.repository);

  Future<OrderEntity?> call(String orderNumber) async {
    if (orderNumber.isEmpty) {
      throw ArgumentError('Order number không được để trống');
    }

    return await repository.getOrderByNumber(orderNumber);
  }
}
