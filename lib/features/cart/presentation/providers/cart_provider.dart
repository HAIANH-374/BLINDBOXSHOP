import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/notification_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/cart_model.dart';
import 'cart_di.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  final cartNotifier = CartNotifier(ref);

  ref.listen(authProvider.select((state) => state.firebaseUser?.uid), (
    previous,
    next,
  ) {
    if (previous != next) {
      cartNotifier.reinitializeCart();
    }
  });

  return cartNotifier;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.length;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalPrice;
});

final cartItemsCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.isEmpty;
});

final cartStreamProvider = StreamProvider<Cart?>((ref) {
  final cartNotifier = ref.watch(cartProvider.notifier);
  return cartNotifier.watchCart();
});

final cartStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final cartNotifier = ref.watch(cartProvider.notifier);
  return cartNotifier.getCartStats();
});

class CartNotifier extends StateNotifier<Cart> {
  final Ref ref;

  CartNotifier(this.ref)
    : super(Cart(userId: 'guest', lastUpdated: DateTime.now())) {
    _initializeCart();
  }

  String get _userId {
    final authState = ref.read(authProvider);
    return authState.firebaseUser?.uid ?? 'guest';
  }

  Future<void> _initializeCart() async {
    try {
      final userId = _userId;

      final authState = ref.read(authProvider);
      if (authState.authUser?.role == 'admin') {
        return;
      }

      final useCase = ref.read(getUserCartUseCaseProvider);
      final cart = await useCase.call(userId);

      if (cart != null) {
        state = Cart.fromEntity(cart);
      }
    } catch (e) {
      NotificationUtils.showGenericError('khởi tạo giỏ hàng');
    }
  }

  Future<void> reinitializeCart() async {
    final userId = _userId;

    state = Cart(userId: userId, lastUpdated: DateTime.now());

    await _initializeCart();
  }

  Future<void> setUserId(String userId) async {
    await _initializeCart();
  }

  Future<bool> addItem(
    String productId,
    String productName,
    double price,
    String productImage, {
    int quantity = 1,
    String productType = 'single',
    int? boxSize,
    int? setSize,
  }) async {
    try {
      final existingItem = state.getItemByProductId(productId);
      if (existingItem != null && existingItem.productType == productType) {
        final newQuantity = existingItem.quantity + quantity;

        final updateUseCase = ref.read(updateItemQuantityUseCaseProvider);
        await updateUseCase.call(
          userId: _userId,
          productId: productId,
          quantity: newQuantity,
        );
        NotificationUtils.showUpdateCartSuccess(productName, newQuantity);
      } else {
        final addUseCase = ref.read(addItemToCartUseCaseProvider);
        await addUseCase.call(
          userId: _userId,
          productId: productId,
          productName: productName,
          price: price,
          productImage: productImage,
          quantity: quantity,
          productType: productType,
          boxSize: boxSize,
          setSize: setSize,
        );
        NotificationUtils.showAddToCartSuccess(productName, quantity);
      }

      await _refreshCart();
      return true;
    } catch (e) {
      NotificationUtils.showGenericError('thêm sản phẩm vào giỏ hàng');
      return false;
    }
  }

  Future<void> updateItemQuantity(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeItem(productId);
        return;
      }

      final useCase = ref.read(updateItemQuantityUseCaseProvider);
      await useCase.call(
        userId: _userId,
        productId: productId,
        quantity: quantity,
      );

      await _refreshCart();
    } catch (e) {
      NotificationUtils.showGenericError('cập nhật số lượng sản phẩm');
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final item = state.getItemByProductId(productId);
      final productName = item?.productName ?? 'Sản phẩm';

      final useCase = ref.read(removeItemFromCartUseCaseProvider);
      await useCase.call(userId: _userId, productId: productId);

      await _refreshCart();

      NotificationUtils.showRemoveFromCartSuccess(productName);
    } catch (e) {
      NotificationUtils.showGenericError('Xóa sản phẩm khỏi giỏ hàng');
    }
  }

  Future<void> clearCart() async {
    try {
      final useCase = ref.read(clearCartUseCaseProvider);
      await useCase.call(_userId);

      state = Cart(userId: _userId, lastUpdated: DateTime.now());
      NotificationUtils.showClearCartSuccess();
    } catch (e) {
      NotificationUtils.showGenericError('xóa giỏ hàng');
    }
  }

  Future<void> _refreshCart() async {
    try {
      final useCase = ref.read(getUserCartUseCaseProvider);
      final cart = await useCase.call(_userId);

      if (cart != null) {
        state = Cart.fromEntity(cart);
      }
    } catch (e) {
      NotificationUtils.showGenericError('làm mới giỏ hàng');
    }
  }

  Future<void> syncCart() async {
    try {
      await _refreshCart();
      NotificationUtils.showSyncSuccess();
    } catch (e) {
      NotificationUtils.showGenericError('đồng bộ giỏ hàng');
    }
  }

  void applyCoupon(String couponCode, int discountAmount) {
    try {
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationUtils.showInfo('Mã giảm giá "$couponCode" đã được áp dụng');
    } catch (e) {
      NotificationUtils.showError('Không thể áp dụng mã giảm giá');
    }
  }

  void removeCoupon() {
    try {
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationUtils.showInfo('Mã giảm giá đã được xóa');
    } catch (e) {
      NotificationUtils.showError('Không thể xóa mã giảm giá');
    }
  }

  void setShippingFee(int fee) {
    try {
      state = state.copyWith(lastUpdated: DateTime.now());
      NotificationUtils.showInfo(
        'Phí vận chuyển đã được cập nhật: ${fee.toStringAsFixed(0)} VNĐ',
      );
    } catch (e) {
      NotificationUtils.showError('Không thể thiết lập phí vận chuyển');
    }
  }

  bool isItemInCart(String productId) {
    return state.items.any((item) => item.productId == productId);
  }

  int getItemQuantity(String productId) {
    try {
      final item = state.items.firstWhere(
        (item) => item.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> getCartStats() async {
    try {
      final useCase = ref.read(getUserCartUseCaseProvider);
      final cart = await useCase.call(_userId);

      if (cart == null) {
        return {
          'totalItems': 0,
          'totalPrice': 0.0,
          'itemCount': 0,
          'isEmpty': true,
          'lastUpdated': null,
        };
      }

      return {
        'totalItems': cart.totalItems,
        'totalPrice': cart.totalPrice,
        'itemCount': cart.items.length,
        'isEmpty': cart.isEmpty,
        'lastUpdated': cart.lastUpdated,
      };
    } catch (e) {
      return {
        'totalItems': 0,
        'totalPrice': 0.0,
        'itemCount': 0,
        'isEmpty': true,
        'lastUpdated': null,
      };
    }
  }

  Stream<Cart?> watchCart() {
    final repository = ref.read(cartRepositoryProvider);
    return repository.watchUserCart(_userId).map((cartEntity) {
      if (cartEntity == null) return null;
      return Cart.fromEntity(cartEntity);
    });
  }
}
