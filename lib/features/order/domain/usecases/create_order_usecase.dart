import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Tạo đơn hàng mới
class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<OrderEntity> call(OrderEntity order) async {
    // Xác thực logic nghiệp vụ
    if (order.userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    if (order.items.isEmpty) {
      throw ArgumentError('Đơn hàng phải có ít nhất 1 sản phẩm');
    }

    if (order.totalAmount <= 0) {
      throw ArgumentError('Tổng tiền đơn hàng không hợp lệ');
    }

    if (order.deliveryAddress == null) {
      throw ArgumentError('Địa chỉ giao hàng không được để trống');
    }

    // Xác thực quy tắc nghiệp vụ trong các item
    for (final item in order.items) {
      if (item.quantity <= 0) {
        throw ArgumentError(
          'Số lượng sản phẩm "${item.productName}" không hợp lệ',
        );
      }
      if (item.price < 0) {
        throw ArgumentError('Giá sản phẩm "${item.productName}" không hợp lệ');
      }
    }

    return await repository.createOrder(order);
  }
}
