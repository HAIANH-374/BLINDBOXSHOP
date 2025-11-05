import '../repositories/order_repository.dart';

/// UseCase: Xác nhận đơn hàng
class ConfirmOrderUseCase {
  final OrderRepository repository;

  ConfirmOrderUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.confirmOrder(orderId);
  }
}
