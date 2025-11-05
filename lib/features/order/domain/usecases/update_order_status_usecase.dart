import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Cập nhật trạng thái đơn hàng
class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<void> call(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.updateOrderStatus(
      orderId,
      status,
      statusNote: statusNote,
      trackingNumber: trackingNumber,
    );
  }
}
