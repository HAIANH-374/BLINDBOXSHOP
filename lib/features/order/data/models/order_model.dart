import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

export '../../domain/entities/order_entity.dart' show OrderStatus, OrderType;

class OrderItem extends OrderItemEntity {
  const OrderItem({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.quantity,
    required super.orderType,
    super.boxSize,
    super.setSize,
    required super.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      orderType: OrderType.values.firstWhere(
        (e) => e.name == data['orderType'],
        orElse: () => OrderType.single,
      ),
      boxSize: data['boxSize'],
      setSize: data['setSize'],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'orderType': orderType.name,
      'boxSize': boxSize,
      'setSize': setSize,
      'totalPrice': totalPrice,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    OrderType? orderType,
    int? boxSize,
    int? setSize,
    double? totalPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      boxSize: boxSize ?? this.boxSize,
      setSize: setSize ?? this.setSize,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

/// Data model cho Order kế thừa từ Entity
/// Xử lý serialization/deserialization cho Firebase
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.orderNumber,
    required super.items,
    required super.subtotal,
    required super.discountAmount,
    required super.shippingFee,
    required super.totalAmount,
    required super.status,
    super.statusNote,
    super.deliveryAddressId,
    super.deliveryAddress,
    super.paymentMethodId,
    super.paymentMethodName,
    super.paymentStatus,
    super.paymentTransactionId,
    super.discountCode,
    super.discountName,
    super.note,
    super.trackingNumber,
    super.estimatedDeliveryDate,
    super.deliveredAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      statusNote: data['statusNote'],
      deliveryAddressId: data['deliveryAddressId'],
      deliveryAddress: data['deliveryAddress'] != null
          ? Map<String, dynamic>.from(data['deliveryAddress'])
          : null,
      paymentMethodId: data['paymentMethodId'],
      paymentMethodName: data['paymentMethodName'],
      paymentStatus: data['paymentStatus'],
      paymentTransactionId: data['paymentTransactionId'],
      discountCode: data['discountCode'],
      discountName: data['discountName'],
      note: data['note'],
      trackingNumber: data['trackingNumber'],
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> data) {
    return OrderModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      statusNote: data['statusNote'],
      deliveryAddressId: data['deliveryAddressId'],
      deliveryAddress: data['deliveryAddress'] != null
          ? Map<String, dynamic>.from(data['deliveryAddress'])
          : null,
      paymentMethodId: data['paymentMethodId'],
      paymentMethodName: data['paymentMethodName'],
      paymentStatus: data['paymentStatus'],
      paymentTransactionId: data['paymentTransactionId'],
      discountCode: data['discountCode'],
      discountName: data['discountName'],
      note: data['note'],
      trackingNumber: data['trackingNumber'],
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => (item as OrderItem).toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'statusNote': statusNote,
      'deliveryAddressId': deliveryAddressId,
      'deliveryAddress': deliveryAddress,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'paymentStatus': paymentStatus,
      'paymentTransactionId': paymentTransactionId,
      'discountCode': discountCode,
      'discountName': discountName,
      'note': note,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Phương thức chuyển đổi
  OrderEntity toEntity() => this;

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      orderNumber: entity.orderNumber,
      items: entity.items
          .map(
            (item) => OrderItem(
              productId: item.productId,
              productName: item.productName,
              productImage: item.productImage,
              price: item.price,
              quantity: item.quantity,
              orderType: item.orderType,
              boxSize: item.boxSize,
              setSize: item.setSize,
              totalPrice: item.totalPrice,
            ),
          )
          .toList(),
      subtotal: entity.subtotal,
      discountAmount: entity.discountAmount,
      shippingFee: entity.shippingFee,
      totalAmount: entity.totalAmount,
      status: entity.status,
      statusNote: entity.statusNote,
      deliveryAddressId: entity.deliveryAddressId,
      deliveryAddress: entity.deliveryAddress,
      paymentMethodId: entity.paymentMethodId,
      paymentMethodName: entity.paymentMethodName,
      paymentStatus: entity.paymentStatus,
      paymentTransactionId: entity.paymentTransactionId,
      discountCode: entity.discountCode,
      discountName: entity.discountName,
      note: entity.note,
      trackingNumber: entity.trackingNumber,
      estimatedDeliveryDate: entity.estimatedDeliveryDate,
      deliveredAt: entity.deliveredAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? discountAmount,
    double? shippingFee,
    double? totalAmount,
    OrderStatus? status,
    String? statusNote,
    String? deliveryAddressId,
    Map<String, dynamic>? deliveryAddress,
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
    String? discountCode,
    String? discountName,
    String? note,
    String? trackingNumber,
    DateTime? estimatedDeliveryDate,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items?.cast<OrderItem>() ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      discountCode: discountCode ?? this.discountCode,
      discountName: discountName ?? this.discountName,
      note: note ?? this.note,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
