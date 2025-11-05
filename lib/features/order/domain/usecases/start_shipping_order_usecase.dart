import '../repositories/order_repository.dart';

/// UseCase: Bắt đầu vận chuyển đơn hàng
class StartShippingOrderUseCase {
  final OrderRepository repository;

  StartShippingOrderUseCase(this.repository);

  Future<void> call(String orderId, {String? trackingNumber}) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.startShippingOrder(
      orderId,
      trackingNumber: trackingNumber,
    );
  }
}
