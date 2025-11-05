// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrderUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isFirstOrder(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where(
            'status',
            whereIn: [
              'confirmed',
              'preparing',
              'shipping',
              'delivered',
              'completed',
            ],
          )
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      return true;
    }
  }

  static Future<int> getCompletedOrdersCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['delivered', 'completed'])
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<double> getTotalSpentAmount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['delivered', 'completed'])
          .get();

      double totalSpent = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final totalAmount = data['totalAmount'] as double? ?? 0.0;
        totalSpent += totalAmount;
      }

      return totalSpent;
    } catch (e) {
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      int totalOrders = snapshot.docs.length;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalSpent = 0.0;
      double totalSaved = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        final totalAmount = data['totalAmount'] as double? ?? 0.0;
        final discountAmount = data['discountAmount'] as double? ?? 0.0;

        if (status == 'delivered' || status == 'completed') {
          completedOrders++;
          totalSpent += totalAmount;
          totalSaved += discountAmount;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        }
      }

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
        'totalSaved': totalSaved,
        'isFirstOrder': completedOrders == 0,
        'averageOrderValue': completedOrders > 0
            ? totalSpent / completedOrders
            : 0.0,
      };
    } catch (e) {
      return {
        'totalOrders': 0,
        'completedOrders': 0,
        'cancelledOrders': 0,
        'totalSpent': 0.0,
        'totalSaved': 0.0,
        'isFirstOrder': true,
        'averageOrderValue': 0.0,
      };
    }
  }

  static Future<List<String>> getEligibleDiscountCodes(String userId) async {
    try {
      final stats = await getUserOrderStats(userId);
      final isFirstOrder = stats['isFirstOrder'] as bool;
      final totalSpent = stats['totalSpent'] as double;
      final completedOrders = stats['completedOrders'] as int;

      List<String> eligibleCodes = [];

      if (isFirstOrder) {
        eligibleCodes.add('WELCOME10');
        eligibleCodes.add('FIRST50K');
      }

      if (totalSpent >= 1000000) {
        eligibleCodes.add('VIP15');
      } else if (totalSpent >= 500000) {
        eligibleCodes.add('LOYAL10');
      }

      if (completedOrders >= 10) {
        eligibleCodes.add('FREQUENT20');
      } else if (completedOrders >= 5) {
        eligibleCodes.add('REGULAR15');
      }

      return eligibleCodes;
    } catch (e) {
      return ['WELCOME10'];
    }
  }
}
