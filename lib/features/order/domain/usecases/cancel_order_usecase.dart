import '../repositories/order_repository.dart';

/// UseCase: Hủy đơn hàng
class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  Future<void> call(String orderId, {String? reason}) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.cancelOrder(orderId, reason: reason);
  }
}
