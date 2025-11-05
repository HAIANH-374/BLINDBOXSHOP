import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  // === CRUD Operations ===
  Future<String> createOrder(Map<String, dynamic> orderData);
  Future<Map<String, dynamic>?> getOrderById(String orderId);
  Future<Map<String, dynamic>?> getOrderByNumber(String orderNumber);
  Future<List<Map<String, dynamic>>> getUserOrders(String userId);
  Future<List<Map<String, dynamic>>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  });
  Future<List<Map<String, dynamic>>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  );
  Future<void> deleteOrder(String orderId);

  // === Update Operations ===
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? statusNote,
    String? trackingNumber,
  });
  Future<void> updatePaymentInfo(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  });

  // === Real-time Streams ===
  Stream<Map<String, dynamic>?> watchOrder(String orderId);
  Stream<List<Map<String, dynamic>>> watchUserOrders(String userId);
  Stream<List<Map<String, dynamic>>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  );

  // === Statistics ===
  Future<Map<String, dynamic>> getUserOrderStats(String userId);
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  });

  // === Search ===
  Future<List<Map<String, dynamic>>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'orders';

  OrderRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final docRef = await _firestore.collection(_collection).add(orderData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrderByNumber(String orderNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    } catch (e) {
      throw Exception('Failed to get order by number: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllOrders({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

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

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersByStatus(
    String userId,
    OrderStatus status,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
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

      if (statusNote != null) {
        updateData['statusNote'] = statusNote;
      }

      if (trackingNumber != null) {
        updateData['trackingNumber'] = trackingNumber;
      }

      // Cập nhật deliveredAt khi status là delivered
      if (status == OrderStatus.delivered) {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updatePaymentInfo(
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

      if (paymentMethodId != null) {
        updateData['paymentMethodId'] = paymentMethodId;
      }
      if (paymentMethodName != null) {
        updateData['paymentMethodName'] = paymentMethodName;
      }
      if (paymentStatus != null) {
        updateData['paymentStatus'] = paymentStatus;
      }
      if (paymentTransactionId != null) {
        updateData['paymentTransactionId'] = paymentTransactionId;
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update payment info: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchOrder(String orderId) {
    try {
      return _firestore.collection(_collection).doc(orderId).snapshots().map((
        doc,
      ) {
        if (!doc.exists) return null;
        return {'id': doc.id, ...doc.data()!};
      });
    } catch (e) {
      throw Exception('Failed to watch order: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserOrders(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to watch user orders: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchOrdersByStatus(
    String userId,
    OrderStatus status,
  ) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to watch orders by status: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final orders = querySnapshot.docs;
      final totalOrders = orders.length;

      var totalSpent = 0.0;
      var completedOrders = 0;
      var cancelledOrders = 0;
      var pendingOrders = 0;

      for (final doc in orders) {
        final data = doc.data();
        final status = OrderStatus.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => OrderStatus.pending,
        );

        final amount = (data['totalAmount'] ?? 0.0).toDouble();

        if (status == OrderStatus.completed ||
            status == OrderStatus.delivered) {
          totalSpent += amount;
          completedOrders++;
        } else if (status == OrderStatus.cancelled ||
            status == OrderStatus.returned) {
          cancelledOrders++;
        } else if (status == OrderStatus.pending) {
          pendingOrders++;
        }
      }

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'pendingOrders': pendingOrders,
        'totalSpent': totalSpent,
        'averageOrderValue': completedOrders > 0
            ? totalSpent / completedOrders
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get user order stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

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

      query = query.where(
        'status',
        whereIn: [OrderStatus.delivered.name, OrderStatus.completed.name],
      );

      final querySnapshot = await query.get();

      // Tổng hợp doanh số sản phẩm
      final productSales = <String, Map<String, dynamic>>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final itemData = item as Map<String, dynamic>;
          final productId = itemData['productId'] as String;
          final quantity = itemData['quantity'] as int;
          final totalPrice = (itemData['totalPrice'] ?? 0.0).toDouble();

          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += quantity;
            productSales[productId]!['revenue'] += totalPrice;
          } else {
            productSales[productId] = {
              'productId': productId,
              'productName': itemData['productName'],
              'productImage': itemData['productImage'],
              'quantity': quantity,
              'revenue': totalPrice,
            };
          }
        }
      }

      // Sắp xếp theo số lượng và lấy top N
      final sortedProducts = productSales.values.toList()
        ..sort(
          (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
        );

      return sortedProducts.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get best selling products: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSlowSellingProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Logic tương tự getBestSellingProducts nhưng sắp xếp tăng dần
      final bestSelling = await getBestSellingProducts(
        limit: 100,
        startDate: startDate,
        endDate: endDate,
      );

      bestSelling.sort(
        (a, b) => (a['quantity'] as int).compareTo(b['quantity'] as int),
      );

      return bestSelling.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get slow selling products: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

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

      query = query.where(
        'status',
        whereIn: [OrderStatus.delivered.name, OrderStatus.completed.name],
      );

      final querySnapshot = await query.get();

      // Tổng hợp chi tiêu của khách hàng
      final customerStats = <String, Map<String, dynamic>>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String;
        final totalAmount = (data['totalAmount'] ?? 0.0).toDouble();

        if (customerStats.containsKey(userId)) {
          customerStats[userId]!['totalSpent'] += totalAmount;
          customerStats[userId]!['orderCount'] += 1;
        } else {
          customerStats[userId] = {
            'userId': userId,
            'totalSpent': totalAmount,
            'orderCount': 1,
          };
        }
      }

      // Sắp xếp theo tổng chi tiêu
      final sortedCustomers = customerStats.values.toList()
        ..sort(
          (a, b) =>
              (b['totalSpent'] as double).compareTo(a['totalSpent'] as double),
        );

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get top customers: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        firestoreQuery = firestoreQuery.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        firestoreQuery = firestoreQuery.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        firestoreQuery = firestoreQuery.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);

      final querySnapshot = await firestoreQuery.get();
      var results = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Client-side filtering by order number or product name if query provided
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        results = results.where((order) {
          final orderNumber = (order['orderNumber'] as String).toLowerCase();
          if (orderNumber.contains(lowercaseQuery)) return true;

          // Tìm kiếm trong các sản phẩm
          final items = order['items'] as List<dynamic>? ?? [];
          return items.any((item) {
            final itemData = item as Map<String, dynamic>;
            final productName = (itemData['productName'] as String)
                .toLowerCase();
            return productName.contains(lowercaseQuery);
          });
        }).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }
}
