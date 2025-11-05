import '../datasources/cart_remote_datasource.dart';
import '../models/cart_model.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  const CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CartEntity?> getUserCart(String userId) async {
    try {
      final data = await remoteDataSource.getUserCart(userId);
      if (data == null) return null;
      return Cart.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Failed to get user cart: $e');
    }
  }

  @override
  Future<bool> addItemToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String productImage,
    int quantity = 1,
    String productType = 'single',
    int? boxSize,
    int? setSize,
  }) async {
    try {
      await remoteDataSource.addItemToCart(
        userId: userId,
        productId: productId,
        productName: productName,
        price: price,
        productImage: productImage,
        quantity: quantity,
        productType: productType,
        boxSize: boxSize,
        setSize: setSize,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<bool> updateItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await remoteDataSource.updateItemQuantity(
        userId: userId,
        productId: productId,
        quantity: quantity,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  @override
  Future<bool> removeItemFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      await remoteDataSource.removeItemFromCart(
        userId: userId,
        productId: productId,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<bool> clearCart(String userId) async {
    try {
      await remoteDataSource.clearCart(userId);
      return true;
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<int> getCartItemCount(String userId) async {
    try {
      return await remoteDataSource.getCartItemCount(userId);
    } catch (e) {
      throw Exception('Failed to get cart item count: $e');
    }
  }

  @override
  Future<bool> updateItem({
    required String userId,
    required String productId,
    String? productType,
    int? boxSize,
    int? setSize,
    int? quantity,
  }) async {
    try {
      if (quantity != null) {
        await remoteDataSource.updateItemQuantity(
          userId: userId,
          productId: productId,
          quantity: quantity,
        );
      }
      return true;
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  @override
  Stream<CartEntity?> watchUserCart(String userId) {
    try {
      return remoteDataSource.watchUserCart(userId).map((data) {
        if (data == null) return null;
        return Cart.fromJson(data).toEntity();
      });
    } catch (e) {
      throw Exception('Failed to watch user cart: $e');
    }
  }
}
