// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/order/data/models/order_model.dart';

class OrderUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  static Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore
          .collection(_ordersCollection)
          .add(order.toFirestore());

      final createdOrder = order.copyWith(
        id: docRef.id,
        orderNumber: _generateOrderNumber(),
      );

      await _firestore.collection(_ordersCollection).doc(docRef.id).update({
        'orderNumber': createdOrder.orderNumber,
      });

      await _updateUserOrderStats(order.userId);

      return createdOrder;
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng: $e');
    }
  }

  static Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      final query = await _firestore
          .collection(_ordersCollection)
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return OrderModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng: $e');
    }
  }

  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final query = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: $e');
    }
  }

  static Future<List<OrderModel>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(_ordersCollection);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy tất cả đơn hàng: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  ) async {
    try {
      final query = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng theo trạng thái: $e');
    }
  }

  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (statusNote != null) updateData['statusNote'] = statusNote;
      if (trackingNumber != null) updateData['trackingNumber'] = trackingNumber;

      if (status == OrderStatus.delivered) {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);

      if (status == OrderStatus.delivered || status == OrderStatus.completed) {
        final order = await getOrderById(orderId);
        if (order != null) {
          await _updateUserOrderStats(order.userId);
        }
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái đơn hàng: $e');
    }
  }

  static Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final updateData = <String, dynamic>{
        'status': OrderStatus.cancelled.name,
        'statusNote': reason ?? 'Khách hàng hủy đơn hàng',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: $e');
    }
  }

  static Future<void> confirmOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.confirmed,
        statusNote: 'Đơn hàng đã được xác nhận',
      );
    } catch (e) {
      throw Exception('Lỗi xác nhận đơn hàng: $e');
    }
  }

  static Future<void> startPreparingOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.preparing,
        statusNote: 'Đang chuẩn bị đơn hàng',
      );
    } catch (e) {
      throw Exception('Lỗi bắt đầu chuẩn bị đơn hàng: $e');
    }
  }

  static Future<void> startShippingOrder(
    String orderId, {
    String? trackingNumber,
  }) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.shipping,
        statusNote: 'Đơn hàng đang được giao',
        trackingNumber: trackingNumber,
      );
    } catch (e) {
      throw Exception('Lỗi bắt đầu giao hàng: $e');
    }
  }

  static Future<void> completeDelivery(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.delivered,
        statusNote: 'Đơn hàng đã được giao thành công',
      );
    } catch (e) {
      throw Exception('Lỗi hoàn thành giao hàng: $e');
    }
  }

  static Future<void> completeOrder(String orderId) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.completed,
        statusNote: 'Đơn hàng đã hoàn thành',
      );
    } catch (e) {
      throw Exception('Lỗi hoàn thành đơn hàng: $e');
    }
  }

  static Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentMethodId != null)
        updateData['paymentMethodId'] = paymentMethodId;
      if (paymentMethodName != null)
        updateData['paymentMethodName'] = paymentMethodName;
      if (paymentStatus != null) updateData['paymentStatus'] = paymentStatus;
      if (paymentTransactionId != null)
        updateData['paymentTransactionId'] = paymentTransactionId;

      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin thanh toán: $e');
    }
  }

  static Stream<OrderModel?> watchOrder(String orderId) {
    return _firestore
        .collection(_ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return OrderModel.fromFirestore(snapshot);
        });
  }

  static Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Lắng nghe đơn hàng theo trạng thái real-time
  static Stream<List<OrderModel>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  ) {
    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  static Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final orders = await getUserOrders(userId);

      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o.status == OrderStatus.pending)
          .length;
      final confirmedOrders = orders
          .where((o) => o.status == OrderStatus.confirmed)
          .length;
      final preparingOrders = orders
          .where((o) => o.status == OrderStatus.preparing)
          .length;
      final shippingOrders = orders
          .where((o) => o.status == OrderStatus.shipping)
          .length;
      final deliveredOrders = orders
          .where((o) => o.status == OrderStatus.delivered)
          .length;
      final completedOrders = orders
          .where((o) => o.status == OrderStatus.completed)
          .length;
      final cancelledOrders = orders
          .where((o) => o.status == OrderStatus.cancelled)
          .length;
      final returnedOrders = orders
          .where((o) => o.status == OrderStatus.returned)
          .length;

      final totalRevenue = orders
          .where(
            (o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.completed,
          )
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0.0;

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'confirmedOrders': confirmedOrders,
        'preparingOrders': preparingOrders,
        'shippingOrders': shippingOrders,
        'deliveredOrders': deliveredOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'returnedOrders': returnedOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': averageOrderValue,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê đơn hàng: $e');
    }
  }

  static Future<List<OrderModel>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query queryRef = _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        queryRef = queryRef.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        queryRef = queryRef.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        queryRef = queryRef.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await queryRef
          .orderBy('createdAt', descending: true)
          .get();

      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Lọc theo từ khóa nếu có
      if (query != null && query.isNotEmpty) {
        orders = orders.where((order) {
          return order.orderNumber.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              order.items.any(
                (item) => item.productName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              );
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm đơn hàng: $e');
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa đơn hàng: $e');
    }
  }

  static String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
  }

  static bool canCancelOrder(OrderModel order) {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed;
  }

  static bool canTrackOrder(OrderModel order) {
    return order.status == OrderStatus.shipping ||
        order.status == OrderStatus.delivered;
  }

  static bool canReviewOrder(OrderModel order) {
    return order.status == OrderStatus.delivered ||
        order.status == OrderStatus.completed;
  }

  static Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> productStats = {};

      for (final order in orders) {
        for (final item in order.items) {
          if (productStats.containsKey(item.productId)) {
            productStats[item.productId]!['quantity'] += item.quantity;
            productStats[item.productId]!['revenue'] +=
                item.price * item.quantity;
          } else {
            productStats[item.productId] = {
              'productId': item.productId,
              'productName': item.productName,
              'productImage': item.productImage,
              'quantity': item.quantity,
              'revenue': item.price * item.quantity,
            };
          }
        }
      }

      final sortedProducts = productStats.values.toList()
        ..sort(
          (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
        );

      return sortedProducts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> productStats = {};

      for (final order in orders) {
        for (final item in order.items) {
          if (productStats.containsKey(item.productId)) {
            productStats[item.productId]!['quantity'] += item.quantity;
          } else {
            productStats[item.productId] = {
              'productId': item.productId,
              'productName': item.productName,
              'productImage': item.productImage,
              'quantity': item.quantity,
            };
          }
        }
      }

      final List<Map<String, dynamic>> products = productStats.values.toList();
      // Sắp xếp tăng dần theo số lượng (sản phẩm bán chậm đầu tiên)
      products.sort(
        (a, b) => (a['quantity'] as int).compareTo(b['quantity'] as int),
      );
      return products.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Sử dụng Firestore indexes cho query phức tạp
      final orders = await getAllOrders(
        startDate: startDate,
        endDate: endDate,
        status: OrderStatus.delivered,
      );

      final Map<String, Map<String, dynamic>> customerStats = {};

      for (final order in orders) {
        if (customerStats.containsKey(order.userId)) {
          customerStats[order.userId]!['orderCount'] += 1;
          customerStats[order.userId]!['totalSpent'] += order.totalAmount;
        } else {
          customerStats[order.userId] = {
            'userId': order.userId,
            'orderCount': 1,
            'totalSpent': order.totalAmount,
          };
        }
      }

      final sortedCustomers = customerStats.values.toList()
        ..sort(
          (a, b) =>
              (b['totalSpent'] as double).compareTo(a['totalSpent'] as double),
        );

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _updateUserOrderStats(String userId) async {
    try {
      // Lấy tất cả đơn hàng của user
      final orders = await getUserOrders(userId);

      // Tính tổng số đơn hàng và tổng tiền đã chi
      final totalOrders = orders.length;
      final totalSpent = orders
          .where(
            (order) =>
                order.status == OrderStatus.delivered ||
                order.status == OrderStatus.completed,
          )
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      // Cập nhật thống kê trong user document
      await _firestore.collection('users').doc(userId).update({
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // ignore: empty_catches
    } catch (e) {}
  }
}
