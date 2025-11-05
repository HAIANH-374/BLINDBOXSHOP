import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../order/presentation/providers/order_di.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../product/presentation/providers/product_di.dart';

class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double todayRevenue;
  final int totalProducts;
  final int lowStockProducts;
  final int totalCustomers;

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalCustomers,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final orderRepository = ref.watch(orderRepositoryProvider);
  final allOrders = await orderRepository.getAllOrders();

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);

  final totalOrders = allOrders.length;
  final pendingOrders = allOrders
      .where(
        (o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed,
      )
      .length;
  final completedOrders = allOrders
      .where((o) => o.status == OrderStatus.delivered)
      .length;
  final cancelledOrders = allOrders
      .where((o) => o.status == OrderStatus.cancelled)
      .length;

  final totalRevenue = allOrders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  final todayRevenue = allOrders
      .where(
        (o) =>
            o.status == OrderStatus.delivered &&
            o.createdAt.isAfter(startOfDay),
      )
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  final productRepository = ref.watch(productRepositoryProvider);
  final allProducts = await productRepository.getProducts();
  final totalProducts = allProducts.length;
  final lowStockProducts = allProducts.where((p) => p.stock < 10).length;

  final uniqueCustomerIds = allOrders.map((o) => o.userId).toSet().length;

  return DashboardStats(
    totalOrders: totalOrders,
    pendingOrders: pendingOrders,
    completedOrders: completedOrders,
    cancelledOrders: cancelledOrders,
    totalRevenue: totalRevenue,
    todayRevenue: todayRevenue,
    totalProducts: totalProducts,
    lowStockProducts: lowStockProducts,
    totalCustomers: uniqueCustomerIds,
  );
});
