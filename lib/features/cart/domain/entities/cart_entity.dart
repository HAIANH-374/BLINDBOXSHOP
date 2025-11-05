class CartItemEntity {
  final String id;
  final String productId;
  final String userId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String productType; // 'single', 'box', 'set'
  final int? boxSize;
  final int? setSize;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.productType = 'single',
    this.boxSize,
    this.setSize,
    required this.addedAt,
    required this.updatedAt,
  });

  // Business Logic Methods

  /// Tính tổng giá cho item này
  double get totalPrice => price * quantity;

  /// Lấy hiển thị giá đã định dạng
  String get formattedPrice => '${price.toStringAsFixed(0)} VNĐ';

  /// Lấy hiển thị tổng giá đã định dạng
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';

  /// Kiểm tra đây có phải sản phẩm box không
  bool get isBoxProduct => productType == 'box';

  /// Kiểm tra đây có phải sản phẩm set không
  bool get isSetProduct => productType == 'set';

  /// Kiểm tra đây có phải sản phẩm đơn không
  bool get isSingleProduct => productType == 'single';

  /// Lấy text hiển thị loại sản phẩm
  String get productTypeText {
    switch (productType) {
      case 'box':
        return 'Hộp ${boxSize ?? ''} sản phẩm';
      case 'set':
        return 'Bộ ${setSize ?? ''} sản phẩm';
      default:
        return 'Sản phẩm đơn';
    }
  }

  /// Kiểm tra có thể tăng số lượng không
  bool canIncreaseQuantity({int maxQuantity = 99}) {
    return quantity < maxQuantity;
  }

  /// Kiểm tra có thể giảm số lượng không
  bool canDecreaseQuantity() {
    return quantity > 1;
  }

  /// Lấy số lượng tiếp theo (để tăng)
  int getIncreasedQuantity() {
    return quantity + 1;
  }

  /// Lấy số lượng trước đó (để giảm)
  int getDecreasedQuantity() {
    return quantity > 1 ? quantity - 1 : 1;
  }

  /// Kiểm tra item có giảm giá không (placeholder cho logic giảm giá trong tương lai)
  bool get hasDiscount => false;

  /// Lấy phần trăm giảm giá (placeholder cho logic giảm giá trong tương lai)
  double get discountPercentage => 0.0;

  /// Lấy giá gốc trước giảm giá (placeholder)
  double get originalPrice => price;

  /// Lấy số tiền tiết kiệm (placeholder)
  double get savings => 0.0;

  /// Kiểm tra item có mới thêm gần đây không (trong vòng 24 giờ qua)
  bool get isRecentlyAdded {
    final now = DateTime.now();
    final difference = now.difference(addedAt);
    return difference.inHours < 24;
  }

  /// Kiểm tra item có được cập nhật gần đây không (trong vòng 1 giờ qua)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 1;
  }

  /// Lấy thời gian kể từ khi thêm (tính theo ngày)
  int get daysSinceAdded {
    final now = DateTime.now();
    return now.difference(addedAt).inDays;
  }

  /// Lấy ngày thêm đã định dạng
  String get formattedAddedDate {
    return '${addedAt.day}/${addedAt.month}/${addedAt.year}';
  }

  /// Lấy ngày cập nhật đã định dạng
  String get formattedUpdatedDate {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  /// Xác thực số lượng là dương
  bool get isValidQuantity => quantity > 0;

  /// Xác thực giá là dương
  bool get isValidPrice => price > 0;

  /// Xác thực item có tất cả dữ liệu bắt buộc
  bool get isValid {
    return id.isNotEmpty &&
        productId.isNotEmpty &&
        userId.isNotEmpty &&
        productName.isNotEmpty &&
        isValidQuantity &&
        isValidPrice;
  }

  /// Tạo bản sao với các trường đã cập nhật
  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? productType,
    int? boxSize,
    int? setSize,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productType: productType ?? this.productType,
      boxSize: boxSize ?? this.boxSize,
      setSize: setSize ?? this.setSize,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItemEntity &&
        other.id == id &&
        other.productId == productId &&
        other.userId == userId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return Object.hash(id, productId, userId, quantity);
  }
}

/// Cart Entity - Pure business object
class CartEntity {
  final String userId;
  final List<CartItemEntity> items;
  final DateTime lastUpdated;

  const CartEntity({
    required this.userId,
    this.items = const [],
    required this.lastUpdated,
  });

  // Business Logic Methods

  /// Lấy tổng số lượng items (tổng các số lượng)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Lấy tổng số lượng sản phẩm duy nhất
  int get uniqueProductCount => items.length;

  /// Tính tổng giá của giỏ hàng
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Lấy hiển thị tổng giá đã định dạng
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} VNĐ';

  /// Kiểm tra giỏ hàng có trống không
  bool get isEmpty => items.isEmpty;

  /// Kiểm tra giỏ hàng có không trống không
  bool get isNotEmpty => items.isNotEmpty;

  /// Kiểm tra giỏ hàng có sản phẩm đơn không
  bool get hasSingleProducts => items.any((item) => item.isSingleProduct);

  /// Kiểm tra giỏ hàng có sản phẩm box không
  bool get hasBoxProducts => items.any((item) => item.isBoxProduct);

  /// Kiểm tra giỏ hàng có sản phẩm set không
  bool get hasSetProducts => items.any((item) => item.isSetProduct);

  /// Lấy chỉ sản phẩm đơn
  List<CartItemEntity> get singleProducts =>
      items.where((item) => item.isSingleProduct).toList();

  /// Lấy chỉ sản phẩm box
  List<CartItemEntity> get boxProducts =>
      items.where((item) => item.isBoxProduct).toList();

  /// Lấy chỉ sản phẩm set
  List<CartItemEntity> get setProducts =>
      items.where((item) => item.isSetProduct).toList();

  /// Lấy item theo ID sản phẩm
  CartItemEntity? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra sản phẩm có tồn tại trong giỏ hàng không
  bool hasProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Lấy số lượng của sản phẩm cụ thể
  int getProductQuantity(String productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  /// Thêm item mới vào giỏ hàng (logic nghiệp vụ)
  CartEntity addItem(CartItemEntity newItem) {
    final existingItem = getItemByProductId(newItem.productId);

    if (existingItem != null) {
      // Cập nhật số lượng nếu item đã tồn tại
      final updatedItems = items.map((item) {
        if (item.productId == newItem.productId) {
          return item.copyWith(
            quantity: item.quantity + newItem.quantity,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      return copyWith(items: updatedItems, lastUpdated: DateTime.now());
    } else {
      // Thêm item mới
      return copyWith(items: [...items, newItem], lastUpdated: DateTime.now());
    }
  }

  /// Cập nhật số lượng item
  CartEntity updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity, updatedAt: DateTime.now());
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems, lastUpdated: DateTime.now());
  }

  /// Tăng số lượng item thêm 1
  CartEntity increaseItemQuantity(String productId) {
    final item = getItemByProductId(productId);
    if (item != null && item.canIncreaseQuantity()) {
      return updateItemQuantity(productId, item.getIncreasedQuantity());
    }
    return this;
  }

  /// Giảm số lượng item xuống 1
  CartEntity decreaseItemQuantity(String productId) {
    final item = getItemByProductId(productId);
    if (item != null && item.canDecreaseQuantity()) {
      return updateItemQuantity(productId, item.getDecreasedQuantity());
    } else if (item != null) {
      return removeItem(productId);
    }
    return this;
  }

  /// Xóa item khỏi giỏ hàng
  CartEntity removeItem(String productId) {
    final updatedItems = items
        .where((item) => item.productId != productId)
        .toList();
    return copyWith(items: updatedItems, lastUpdated: DateTime.now());
  }

  /// Xóa tất cả items khỏi giỏ hàng
  CartEntity clear() {
    return copyWith(items: [], lastUpdated: DateTime.now());
  }

  /// Lấy tổng phụ (trước phí ship, thuế, etc.)
  double get subtotal => totalPrice;

  /// Lấy tổng phụ đã định dạng
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} VNĐ';

  /// Tính phí ship ước tính (placeholder cho logic nghiệp vụ)
  double get estimatedShippingFee {
    // Miễn phí ship cho đơn hàng trên 500,000 VNĐ
    if (totalPrice >= 500000) return 0.0;
    // Phí ship tiêu chuẩn
    return 30000.0;
  }

  /// Lấy phí ship đã định dạng
  String get formattedShippingFee =>
      '${estimatedShippingFee.toStringAsFixed(0)} VNĐ';

  /// Kiểm tra có đủ điều kiện miễn phí ship không
  bool get hasFreeShipping => estimatedShippingFee == 0;

  /// Số tiền cần để miễn phí ship
  double get amountForFreeShipping {
    if (hasFreeShipping) return 0;
    return 500000 - totalPrice;
  }

  /// Lấy số tiền cần cho miễn phí ship đã định dạng
  String get formattedAmountForFreeShipping =>
      '${amountForFreeShipping.toStringAsFixed(0)} VNĐ';

  /// Tính tổng cộng với phí ship
  double get totalWithShipping => totalPrice + estimatedShippingFee;

  /// Lấy tổng cộng với phí ship đã định dạng
  String get formattedTotalWithShipping =>
      '${totalWithShipping.toStringAsFixed(0)} VNĐ';

  /// Lấy tổng tiết kiệm (tổng tiết kiệm của tất cả items)
  double get totalSavings => items.fold(0.0, (sum, item) => sum + item.savings);

  /// Kiểm tra giỏ hàng có giảm giá nào không
  bool get hasDiscounts => items.any((item) => item.hasDiscount);

  /// Lấy tổng tiết kiệm đã định dạng
  String get formattedTotalSavings => '${totalSavings.toStringAsFixed(0)} VNĐ';

  /// Kiểm tra giỏ hàng có được cập nhật gần đây không (trong vòng 1 giờ)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours < 1;
  }

  /// Lấy ngày cập nhật cuối đã định dạng
  String get formattedLastUpdated {
    return '${lastUpdated.day}/${lastUpdated.month}/${lastUpdated.year}';
  }

  /// Xác thực tất cả items trong giỏ hàng
  bool get hasValidItems => items.every((item) => item.isValid);

  /// Lấy các items không hợp lệ
  List<CartItemEntity> get invalidItems =>
      items.where((item) => !item.isValid).toList();

  /// Kiểm tra giỏ hàng có hợp lệ để thanh toán không
  bool get canCheckout => isNotEmpty && hasValidItems;

  /// Lấy thông báo xác thực thanh toán
  String? get checkoutValidationMessage {
    if (isEmpty) return 'Giỏ hàng trống';
    if (!hasValidItems) return 'Có sản phẩm không hợp lệ trong giỏ hàng';
    return null;
  }

  /// Lấy items được sắp xếp theo ngày thêm (mới nhất trước)
  List<CartItemEntity> get itemsSortedByNewest {
    final sortedItems = List<CartItemEntity>.from(items);
    sortedItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sortedItems;
  }

  /// Lấy items được sắp xếp theo giá (cao nhất trước)
  List<CartItemEntity> get itemsSortedByPrice {
    final sortedItems = List<CartItemEntity>.from(items);
    sortedItems.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    return sortedItems;
  }

  /// Tạo bản sao với các trường đã cập nhật
  CartEntity copyWith({
    String? userId,
    List<CartItemEntity>? items,
    DateTime? lastUpdated,
  }) {
    return CartEntity(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartEntity &&
        other.userId == userId &&
        other.items.length == items.length;
  }

  @override
  int get hashCode {
    return Object.hash(userId, items.length, lastUpdated);
  }
}
