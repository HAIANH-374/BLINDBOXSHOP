import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Lấy tất cả đơn hàng (Admin)
class GetAllOrdersUseCase {
  final OrderRepository repository;

  GetAllOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return await repository.getAllOrders(
      status: status,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}
