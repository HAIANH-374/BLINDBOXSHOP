import '../repositories/order_repository.dart';

/// UseCase: Hoàn thành giao hàng
class CompleteDeliveryUseCase {
  final OrderRepository repository;

  CompleteDeliveryUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.completeDelivery(orderId);
  }
}
