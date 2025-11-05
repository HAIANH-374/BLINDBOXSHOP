import '../entities/order_entity.dart';

/// Repository interface cho Order feature
/// Tuân thủ Clean Architecture - Domain Layer không phụ thuộc vào Data Layer
abstract class OrderRepository {
  // === CRUD Operations ===

  /// Tạo đơn hàng mới
  Future<OrderEntity> createOrder(OrderEntity order);

  /// Lấy đơn hàng theo ID
  Future<OrderEntity?> getOrderById(String orderId);

  /// Lấy đơn hàng theo số đơn hàng
  Future<OrderEntity?> getOrderByNumber(String orderNumber);

  /// Lấy danh sách đơn hàng của user
  Future<List<OrderEntity>> getUserOrders(String userId);

  /// Lấy tất cả đơn hàng (role admin)
  Future<List<OrderEntity>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  });

  /// Lấy đơn hàng theo trạng thái
  Future<List<OrderEntity>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  );

  /// Xóa đơn hàng (chỉ admin)
  Future<void> deleteOrder(String orderId);

  // === Update Operations ===

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  });

  /// Hủy đơn hàng
  Future<void> cancelOrder(String orderId, {String? reason});

  /// Xác nhận đơn hàng
  Future<void> confirmOrder(String orderId);

  /// Bắt đầu chuẩn bị đơn hàng
  Future<void> startPreparingOrder(String orderId);

  /// Bắt đầu giao hàng
  Future<void> startShippingOrder(String orderId, {String? trackingNumber});

  /// Hoàn thành giao hàng
  Future<void> completeDelivery(String orderId);

  /// Hoàn thành đơn hàng
  Future<void> completeOrder(String orderId);

  /// Cập nhật thông tin thanh toán
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  });

  // === Real-time Streams ===

  /// Lắng nghe thay đổi đơn hàng real-time
  Stream<OrderEntity?> watchOrder(String orderId);

  /// Lắng nghe danh sách đơn hàng của user real-time
  Stream<List<OrderEntity>> watchUserOrders(String userId);

  /// Lắng nghe đơn hàng theo trạng thái real-time
  Stream<List<OrderEntity>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  );

  // === Statistics & Analytics ===

  /// Lấy thống kê đơn hàng của user
  Future<Map<String, dynamic>> getUserOrderStats(String userId);

  /// Lấy sản phẩm bán chạy nhất
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Lấy sản phẩm bán chậm nhất
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Lấy khách hàng mua nhiều nhất
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  // === Search & Filter ===

  /// Tìm kiếm đơn hàng
  Future<List<OrderEntity>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  // === Validation Helpers ===

  /// Kiểm tra đơn hàng có thể hủy không
  bool canCancelOrder(OrderEntity order);

  /// Kiểm tra đơn hàng có thể theo dõi không
  bool canTrackOrder(OrderEntity order);

  /// Kiểm tra đơn hàng có thể đánh giá không
  bool canReviewOrder(OrderEntity order);
}
