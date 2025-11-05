import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

/// UseCase: Tìm kiếm đơn hàng
class SearchOrdersUseCase {
  final OrderRepository repository;

  SearchOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID không được để trống');
    }

    return await repository.searchOrders(
      userId,
      query: query,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
