import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/notification_utils.dart';
import '../../domain/entities/order_entity.dart';
import 'order_di.dart';

// Provider trạng thái đơn hàng
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderEntity>>(
  (ref) {
    return OrdersNotifier(ref);
  },
);

// Provider lịch sử đơn hàng
final orderHistoryProvider = Provider<List<OrderEntity>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.status != OrderStatus.pending).toList();
});

// Provider đơn hàng chờ xử lý
final pendingOrdersProvider = Provider<List<OrderEntity>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.status == OrderStatus.pending).toList();
});

// Provider đơn hàng theo trạng thái
final ordersByStatusProvider = Provider.family<List<OrderEntity>, String>((
  ref,
  status,
) {
  final orders = ref.watch(ordersProvider);
  if (status == 'Tất cả') {
    return orders;
  }
  return orders
      .where(
        (order) =>
            order.status.toString().split('.').last == status.toLowerCase(),
      )
      .toList();
});

// Provider đơn hàng hiện tại
final currentOrderProvider =
    StateNotifierProvider<CurrentOrderNotifier, OrderEntity?>((ref) {
      return CurrentOrderNotifier(ref);
    });

// Provider thống kê đơn hàng (local)
final localOrderStatsProvider = Provider<OrderStats>((ref) {
  final orders = ref.watch(ordersProvider);
  return OrderStats.fromOrders(orders);
});

class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;

  OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });

  factory OrderStats.fromOrders(List<OrderEntity> orders) {
    final totalOrders = orders.length;
    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final confirmedOrders = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .length;
    final shippedOrders = orders
        .where((o) => o.status == OrderStatus.shipping)
        .length;
    final deliveredOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final cancelledOrders = orders
        .where((o) => o.status == OrderStatus.cancelled)
        .length;

    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (total, order) => total + order.totalAmount);

    final averageOrderValue = totalOrders > 0
        ? totalRevenue / totalOrders
        : 0.0;

    return OrderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      confirmedOrders: confirmedOrders,
      shippedOrders: shippedOrders,
      deliveredOrders: deliveredOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
    );
  }
}

class OrdersNotifier extends StateNotifier<List<OrderEntity>> {
  final Ref ref;

  OrdersNotifier(this.ref) : super([]);

  /// Lấy danh sách đơn hàng của user
  Future<void> loadUserOrders(String userId) async {
    try {
      final useCase = ref.read(getUserOrdersUseCaseProvider);
      final orders = await useCase.call(userId);
      state = orders;
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi tải danh sách đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Lấy đơn hàng theo trạng thái
  Future<void> loadOrdersByStatus(String userId, OrderStatus status) async {
    try {
      final useCase = ref.read(getOrdersByStatusUseCaseProvider);
      final orders = await useCase.call(userId, status);
      state = orders;
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi tải đơn hàng theo trạng thái: ${e.toString()}',
      );
    }
  }

  /// Tìm kiếm đơn hàng
  Future<void> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final useCase = ref.read(searchOrdersUseCaseProvider);
      final orders = await useCase.call(
        userId,
        query: query,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      state = orders;
    } catch (e) {
      NotificationUtils.showError('Lỗi tìm kiếm đơn hàng: ${e.toString()}');
    }
  }

  /// Tạo đơn hàng mới
  Future<void> createOrder(OrderEntity order) async {
    try {
      final useCase = ref.read(createOrderUseCaseProvider);
      final createdOrder = await useCase.call(order);
      state = [createdOrder, ...state];
      NotificationUtils.showSuccess('Tạo đơn hàng thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi tạo đơn hàng: ${e.toString()}');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    try {
      final useCase = ref.read(updateOrderStatusUseCaseProvider);
      await useCase.call(
        orderId,
        status,
        statusNote: statusNote,
        trackingNumber: trackingNumber,
      );

      // Cập nhật local state
      final index = state.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderEntity>.from(state);
        updatedOrders[index] = updatedOrders[index].copyWith(
          status: status,
          statusNote: statusNote,
          trackingNumber: trackingNumber,
          updatedAt: DateTime.now(),
        );
        state = updatedOrders;
      }

      NotificationUtils.showSuccess('Cập nhật trạng thái đơn hàng thành công!');
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi cập nhật trạng thái đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final useCase = ref.read(cancelOrderUseCaseProvider);
      await useCase.call(orderId, reason: reason);
      await updateOrderStatus(
        orderId,
        OrderStatus.cancelled,
        statusNote: reason,
      );
      NotificationUtils.showSuccess('Hủy đơn hàng thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi hủy đơn hàng: ${e.toString()}');
    }
  }

  /// Xác nhận đơn hàng
  Future<void> confirmOrder(String orderId) async {
    try {
      final useCase = ref.read(confirmOrderUseCaseProvider);
      await useCase.call(orderId);
      await updateOrderStatus(orderId, OrderStatus.confirmed);
      NotificationUtils.showSuccess('Xác nhận đơn hàng thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi xác nhận đơn hàng: ${e.toString()}');
    }
  }

  /// Bắt đầu chuẩn bị đơn hàng
  Future<void> startPreparingOrder(String orderId) async {
    try {
      final useCase = ref.read(startPreparingOrderUseCaseProvider);
      await useCase.call(orderId);
      await updateOrderStatus(orderId, OrderStatus.preparing);
      NotificationUtils.showSuccess('Bắt đầu chuẩn bị đơn hàng!');
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi bắt đầu chuẩn bị đơn hàng: ${e.toString()}',
      );
    }
  }

  /// Bắt đầu giao hàng
  Future<void> shipOrder(String orderId, {String? trackingNumber}) async {
    try {
      final useCase = ref.read(startShippingOrderUseCaseProvider);
      await useCase.call(orderId, trackingNumber: trackingNumber);
      await updateOrderStatus(
        orderId,
        OrderStatus.shipping,
        trackingNumber: trackingNumber,
      );
      NotificationUtils.showSuccess('Bắt đầu giao hàng!');
    } catch (e) {
      NotificationUtils.showError('Lỗi bắt đầu giao hàng: ${e.toString()}');
    }
  }

  /// Hoàn thành giao hàng
  Future<void> deliverOrder(String orderId) async {
    try {
      final useCase = ref.read(completeDeliveryUseCaseProvider);
      await useCase.call(orderId);
      await updateOrderStatus(orderId, OrderStatus.delivered);
      NotificationUtils.showSuccess('Giao hàng thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi hoàn thành giao hàng: ${e.toString()}');
    }
  }

  /// Hoàn thành đơn hàng
  Future<void> completeOrder(String orderId) async {
    try {
      final useCase = ref.read(completeOrderUseCaseProvider);
      await useCase.call(orderId);
      await updateOrderStatus(orderId, OrderStatus.completed);
      NotificationUtils.showSuccess('Hoàn thành đơn hàng!');
    } catch (e) {
      NotificationUtils.showError('Lỗi hoàn thành đơn hàng: ${e.toString()}');
    }
  }

  /// Lấy đơn hàng theo ID
  OrderEntity? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Lấy đơn hàng theo trạng thái (local)
  List<OrderEntity> getOrdersByStatus(String status) {
    if (status == 'Tất cả') {
      return state;
    }
    return state
        .where(
          (order) =>
              order.status.toString().split('.').last == status.toLowerCase(),
        )
        .toList();
  }

  /// Lấy đơn hàng theo user (local)
  List<OrderEntity> getOrdersByUser(String userId) {
    return state.where((order) => order.userId == userId).toList();
  }

  /// Cập nhật thông tin thanh toán
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    try {
      final useCase = ref.read(updatePaymentInfoUseCaseProvider);
      await useCase.call(
        orderId,
        paymentMethodId: paymentMethodId,
        paymentMethodName: paymentMethodName,
        paymentStatus: paymentStatus,
        paymentTransactionId: paymentTransactionId,
      );

      // Cập nhật local state
      final index = state.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderEntity>.from(state);
        updatedOrders[index] = updatedOrders[index].copyWith(
          paymentMethodId: paymentMethodId,
          paymentMethodName: paymentMethodName,
          paymentStatus: paymentStatus,
          paymentTransactionId: paymentTransactionId,
          updatedAt: DateTime.now(),
        );
        state = updatedOrders;
      }

      NotificationUtils.showSuccess(
        'Cập nhật thông tin thanh toán thành công!',
      );
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi cập nhật thông tin thanh toán: ${e.toString()}',
      );
    }
  }
}

class CurrentOrderNotifier extends StateNotifier<OrderEntity?> {
  final Ref ref;

  CurrentOrderNotifier(this.ref) : super(null);

  /// Đặt đơn hàng hiện tại
  void setCurrentOrder(OrderEntity order) {
    state = order;
  }

  /// Xóa đơn hàng hiện tại
  void clearCurrentOrder() {
    state = null;
  }

  /// Cập nhật đơn hàng hiện tại
  void updateOrder(OrderEntity order) {
    state = order;
  }

  /// Tải đơn hàng theo ID
  Future<void> loadOrderById(String orderId) async {
    try {
      final useCase = ref.read(getOrderByIdUseCaseProvider);
      final order = await useCase.call(orderId);
      if (order != null) {
        state = order;
      } else {
        NotificationUtils.showWarning('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      NotificationUtils.showError('Lỗi tải đơn hàng: ${e.toString()}');
    }
  }

  /// Tải đơn hàng theo số đơn hàng
  Future<void> loadOrderByNumber(String orderNumber) async {
    try {
      final useCase = ref.read(getOrderByNumberUseCaseProvider);
      final order = await useCase.call(orderNumber);
      if (order != null) {
        state = order;
      } else {
        NotificationUtils.showWarning('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      NotificationUtils.showError('Lỗi tải đơn hàng: ${e.toString()}');
    }
  }
}

// Stream providers cho cập nhật real-time
final orderStreamProvider = StreamProvider.family<OrderEntity?, String>((
  ref,
  orderId,
) {
  final repository = ref.read(orderRepositoryProvider);
  return repository.watchOrder(orderId);
});

final userOrdersStreamProvider =
    StreamProvider.family<List<OrderEntity>, String>((ref, userId) {
      final repository = ref.read(orderRepositoryProvider);
      return repository.watchUserOrders(userId);
    });

final ordersByStatusStreamProvider =
    StreamProvider.family<List<OrderEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final userId = params['userId'] as String;
      final status = params['status'] as OrderStatus;
      final repository = ref.read(orderRepositoryProvider);
      return repository.watchOrdersByStatus(userId, status);
    });

// Provider thống kê đơn hàng
final orderStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  userId,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return await repository.getUserOrderStats(userId);
});
