import '../repositories/order_repository.dart';

/// UseCase: Bắt đầu chuẩn bị đơn hàng
class StartPreparingOrderUseCase {
  final OrderRepository repository;

  StartPreparingOrderUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.startPreparingOrder(orderId);
  }
}
