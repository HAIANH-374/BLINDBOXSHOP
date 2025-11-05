import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  const OrderRepositoryImpl({required this.remoteDataSource});

  // === CRUD Operations ===

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    final id = await remoteDataSource.createOrder(model.toFirestore());
    final data = await remoteDataSource.getOrderById(id);
    return OrderModel.fromMap(data!).toEntity();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final data = await remoteDataSource.getOrderById(orderId);
    if (data == null) return null;
    return OrderModel.fromMap(data).toEntity();
  }

  @override
  Future<OrderEntity?> getOrderByNumber(String orderNumber) async {
    final data = await remoteDataSource.getOrderByNumber(orderNumber);
    if (data == null) return null;
    return OrderModel.fromMap(data).toEntity();
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    final dataList = await remoteDataSource.getUserOrders(userId);
    return dataList.map((data) => OrderModel.fromMap(data).toEntity()).toList();
  }

  @override
  Future<List<OrderEntity>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  }) async {
    final dataList = await remoteDataSource.getAllOrders(
      startDate: startDate,
      endDate: endDate,
      status: status,
      limit: limit,
    );
    return dataList.map((data) => OrderModel.fromMap(data).toEntity()).toList();
  }

  @override
  Future<List<OrderEntity>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  ) async {
    final dataList = await remoteDataSource.getOrdersByStatus(userId, status);
    return dataList.map((data) => OrderModel.fromMap(data).toEntity()).toList();
  }

  @override
  Future<void> deleteOrder(String orderId) {
    return remoteDataSource.deleteOrder(orderId);
  }

  // === Update Operations ===

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) {
    return remoteDataSource.updateOrderStatus(
      orderId,
      status,
      statusNote: statusNote,
      trackingNumber: trackingNumber,
    );
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) {
    return updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      statusNote: reason,
    );
  }

  @override
  Future<void> confirmOrder(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  @override
  Future<void> startPreparingOrder(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.preparing);
  }

  @override
  Future<void> startShippingOrder(String orderId, {String? trackingNumber}) {
    return updateOrderStatus(
      orderId,
      OrderStatus.shipping,
      trackingNumber: trackingNumber,
    );
  }

  @override
  Future<void> completeDelivery(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.delivered);
  }

  @override
  Future<void> completeOrder(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.completed);
  }

  @override
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) {
    return remoteDataSource.updatePaymentInfo(
      orderId,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      paymentStatus: paymentStatus,
      paymentTransactionId: paymentTransactionId,
    );
  }

  // === Real-time Streams ===

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return remoteDataSource
        .watchOrder(orderId)
        .map(
          (data) => data != null ? OrderModel.fromMap(data).toEntity() : null,
        );
  }

  @override
  Stream<List<OrderEntity>> watchUserOrders(String userId) {
    return remoteDataSource
        .watchUserOrders(userId)
        .map(
          (dataList) => dataList
              .map((data) => OrderModel.fromMap(data).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<OrderEntity>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  ) {
    return remoteDataSource
        .watchOrdersByStatus(userId, status)
        .map(
          (dataList) => dataList
              .map((data) => OrderModel.fromMap(data).toEntity())
              .toList(),
        );
  }

  // === Statistics & Analytics ===

  @override
  Future<Map<String, dynamic>> getUserOrderStats(String userId) {
    return remoteDataSource.getUserOrderStats(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return remoteDataSource.getBestSellingProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return remoteDataSource.getSlowSellingProducts(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return remoteDataSource.getTopCustomers(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // === Search & Filter ===

  @override
  Future<List<OrderEntity>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dataList = await remoteDataSource.searchOrders(
      userId,
      query: query,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
    return dataList.map((data) => OrderModel.fromMap(data).toEntity()).toList();
  }

  // === Validation Helpers ===

  @override
  bool canCancelOrder(OrderEntity order) => order.canCancel;

  @override
  bool canTrackOrder(OrderEntity order) => order.canTrack;

  @override
  bool canReviewOrder(OrderEntity order) => order.canReview;
}
