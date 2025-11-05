import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CartRemoteDataSource {
  Future<Map<String, dynamic>?> getUserCart(String userId);

  Future<void> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    required int quantity,
    required String productType,
    int? boxSize,
    int? setSize,
  });

  Future<void> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  });

  Future<void> removeItemFromCart({
    required String userId,
    required String productId,
  });

  Future<void> clearCart(String userId);

  Future<int> getCartItemCount(String userId);

  Stream<Map<String, dynamic>?> watchUserCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore firestore;

  const CartRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _cartsCollection => firestore.collection('carts');

  @override
  Future<Map<String, dynamic>?> getUserCart(String userId) async {
    try {
      final doc = await _cartsCollection.doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] ?? [];

        return {
          'user_id': userId,
          'items': items,
          'last_updated':
              (data['last_updated'] as Timestamp?)
                  ?.toDate()
                  .toIso8601String() ??
              DateTime.now().toIso8601String(),
        };
      }

      return {
        'user_id': userId,
        'items': [],
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get user cart: $e');
    }
  }

  @override
  Future<void> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    required int quantity,
    required String productType,
    int? boxSize,
    int? setSize,
  }) async {
    try {
      final cartRef = _cartsCollection.doc(userId);
      final cartDoc = await cartRef.get();

      final now = Timestamp.now();
      final itemId = '${userId}_${productId}';

      final newItem = {
        'id': itemId,
        'product_id': productId,
        'user_id': userId,
        'product_name': productName,
        'product_image': productImage,
        'price': price,
        'quantity': quantity,
        'product_type': productType,
        'box_size': boxSize,
        'set_size': setSize,
        'added_at': now,
        'updated_at': now,
      };

      if (cartDoc.exists) {
        final data = cartDoc.data() as Map<String, dynamic>;
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

        final existingIndex = items.indexWhere(
          (item) => item['product_id'] == productId,
        );

        if (existingIndex != -1) {
          items[existingIndex]['quantity'] =
              (items[existingIndex]['quantity'] as int) + quantity;
          items[existingIndex]['updated_at'] = now;
        } else {
          items.add(newItem);
        }

        await cartRef.update({'items': items, 'last_updated': now});
      } else {
        await cartRef.set({
          'user_id': userId,
          'items': [newItem],
          'last_updated': now,
          'created_at': now,
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<void> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final cartRef = _cartsCollection.doc(userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      final data = cartDoc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      if (quantity <= 0) {
        items.removeWhere((item) => item['product_id'] == productId);
      } else {
        final itemIndex = items.indexWhere(
          (item) => item['product_id'] == productId,
        );

        if (itemIndex != -1) {
          items[itemIndex]['quantity'] = quantity;
          items[itemIndex]['updated_at'] = Timestamp.now();
        }
      }

      await cartRef.update({'items': items, 'last_updated': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<void> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cartRef = _cartsCollection.doc(userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      final data = cartDoc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      items.removeWhere((item) => item['product_id'] == productId);

      await cartRef.update({'items': items, 'last_updated': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final cartRef = _cartsCollection.doc(userId);
      await cartRef.update({'items': [], 'last_updated': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<int> getCartItemCount(String userId) async {
    try {
      final cartData = await getUserCart(userId);
      if (cartData == null) return 0;

      final items = cartData['items'] as List<dynamic>? ?? [];
      return items.fold<int>(
        0,
        (sum, item) => sum + ((item['quantity'] as int?) ?? 0),
      );
    } catch (e) {
      throw Exception('Failed to get cart item count: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchUserCart(String userId) {
    try {
      return _cartsCollection.doc(userId).snapshots().map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'user_id': userId,
            'items': data['items'] ?? [],
            'last_updated':
                (data['last_updated'] as Timestamp?)
                    ?.toDate()
                    .toIso8601String() ??
                DateTime.now().toIso8601String(),
          };
        }
        return {
          'user_id': userId,
          'items': [],
          'last_updated': DateTime.now().toIso8601String(),
        };
      });
    } catch (e) {
      throw Exception('Failed to watch user cart: $e');
    }
  }
}
