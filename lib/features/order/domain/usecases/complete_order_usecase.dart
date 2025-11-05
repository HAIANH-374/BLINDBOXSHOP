import '../repositories/order_repository.dart';

/// UseCase: Hoàn thành đơn hàng
class CompleteOrderUseCase {
  final OrderRepository repository;

  CompleteOrderUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.completeOrder(orderId);
  }
}
