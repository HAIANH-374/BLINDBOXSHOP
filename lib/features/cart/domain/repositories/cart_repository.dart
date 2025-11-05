import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity?> getUserCart(String userId);

  Future<bool> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    int quantity,
    String productType,
    int? boxSize,
    int? setSize,
  });

  Future<bool> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  });

  Future<bool> removeItemFromCart({
    required String userId,
    required String productId,
  });

  Future<bool> clearCart(String userId);

  Future<int> getCartItemCount(String userId);

  Future<bool> updateItem({
    required String userId,
    required String productId,
    String? productType,
    int? boxSize,
    int? setSize,
    int? quantity,
  });

  Stream<CartEntity?> watchUserCart(String userId);
}
