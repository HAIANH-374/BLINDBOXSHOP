import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_entity.dart';

class CartItem extends CartItemEntity {
  const CartItem({
    required super.id,
    required super.productId,
    required super.userId,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.quantity,
    super.productType,
    super.boxSize,
    super.setSize,
    required super.addedAt,
    required super.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      productType: json['product_type'] as String? ?? 'single',
      boxSize: json['box_size'] as int?,
      setSize: json['set_size'] as int?,
      addedAt: _parseDateTime(json['added_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'product_type': productType,
      'box_size': boxSize,
      'set_size': setSize,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      userId: userId,
      productName: productName,
      productImage: productImage,
      price: price,
      quantity: quantity,
      productType: productType,
      boxSize: boxSize,
      setSize: setSize,
      addedAt: addedAt,
      updatedAt: updatedAt,
    );
  }

  factory CartItem.fromEntity(CartItemEntity entity) {
    return CartItem(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      productName: entity.productName,
      productImage: entity.productImage,
      price: entity.price,
      quantity: entity.quantity,
      productType: entity.productType,
      boxSize: entity.boxSize,
      setSize: entity.setSize,
      addedAt: entity.addedAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  CartItem copyWith({
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
    return CartItem(
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
}

class Cart extends CartEntity {
  const Cart({required super.userId, super.items, required super.lastUpdated});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['user_id'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: CartItem._parseDateTime(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'items': items.map((e) => (e as CartItem).toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  CartEntity toEntity() => this;

  factory Cart.fromEntity(CartEntity entity) {
    return Cart(
      userId: entity.userId,
      items: entity.items
          .map((item) => item is CartItem ? item : CartItem.fromEntity(item))
          .toList(),
      lastUpdated: entity.lastUpdated,
    );
  }

  @override
  Cart copyWith({
    String? userId,
    List<CartItemEntity>? items,
    DateTime? lastUpdated,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
