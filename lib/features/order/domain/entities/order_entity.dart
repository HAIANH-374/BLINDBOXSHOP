import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum OrderStatus {
  pending, // Chờ xác nhận
  confirmed, // Đã xác nhận
  preparing, // Đang chuẩn bị
  shipping, // Đang giao hàng
  delivered, // Đã giao hàng
  completed, // Hoàn thành
  cancelled, // Đã hủy
  returned, // Đã trả hàng
}

enum OrderType {
  single, // Đơn lẻ
  box, // Theo box
  set, // Theo set
}

class OrderItemEntity {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final OrderType orderType;
  final int? boxSize;
  final int? setSize;
  final double totalPrice;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.orderType,
    this.boxSize,
    this.setSize,
    required this.totalPrice,
  });

  bool get isBoxOrder => orderType == OrderType.box;

  bool get isSetOrder => orderType == OrderType.set;

  bool get isSingleOrder => orderType == OrderType.single;

  String get orderTypeText {
    switch (orderType) {
      case OrderType.single:
        return 'Đơn lẻ';
      case OrderType.box:
        return 'Box ${boxSize ?? 0} món';
      case OrderType.set:
        return 'Set ${setSize ?? 0} món';
    }
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  OrderItemEntity copyWith({
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
    return OrderItemEntity(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemEntity &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          productImage == other.productImage &&
          price == other.price &&
          quantity == other.quantity &&
          orderType == other.orderType &&
          boxSize == other.boxSize &&
          setSize == other.setSize &&
          totalPrice == other.totalPrice;

  @override
  int get hashCode =>
      productId.hashCode ^
      productName.hashCode ^
      productImage.hashCode ^
      price.hashCode ^
      quantity.hashCode ^
      orderType.hashCode ^
      boxSize.hashCode ^
      setSize.hashCode ^
      totalPrice.hashCode;
}

class OrderEntity {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double totalAmount;
  final OrderStatus status;
  final String? statusNote;
  final String? deliveryAddressId;
  final Map<String, dynamic>? deliveryAddress;
  final String? paymentMethodId;
  final String? paymentMethodName;
  final String? paymentStatus;
  final String? paymentTransactionId;
  final String? discountCode;
  final String? discountName;
  final String? note;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.totalAmount,
    required this.status,
    this.statusNote,
    this.deliveryAddressId,
    this.deliveryAddress,
    this.paymentMethodId,
    this.paymentMethodName,
    this.paymentStatus,
    this.paymentTransactionId,
    this.discountCode,
    this.discountName,
    this.note,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.shipping:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.shipping:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.returned:
        return AppColors.textSecondary;
    }
  }

  bool get canCancel {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get canTrack {
    return status == OrderStatus.shipping || status == OrderStatus.delivered;
  }

  bool get canReview {
    return status == OrderStatus.delivered || status == OrderStatus.completed;
  }

  bool get isPending => status == OrderStatus.pending;

  bool get isConfirmed => status == OrderStatus.confirmed;

  bool get isInProgress =>
      status == OrderStatus.preparing || status == OrderStatus.shipping;

  bool get isSuccessful =>
      status == OrderStatus.delivered || status == OrderStatus.completed;

  bool get isCancelled =>
      status == OrderStatus.cancelled || status == OrderStatus.returned;

  bool get isPaymentCompleted =>
      paymentStatus?.toLowerCase() == 'completed' ||
      paymentStatus?.toLowerCase() == 'success';

  bool get isPaymentPending =>
      paymentStatus?.toLowerCase() == 'pending' || paymentStatus == null;

  bool get isPaymentFailed => paymentStatus?.toLowerCase() == 'failed';

  bool get hasDiscount => discountAmount > 0 && discountCode != null;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return (discountAmount / (subtotal + discountAmount)) * 100;
  }

  String get formattedDiscountPercentage {
    if (!hasDiscount) return '0%';
    return '${discountPercentage.toStringAsFixed(0)}%';
  }

  double get savings => discountAmount;

  bool get isFreeShipping => shippingFee == 0;

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get uniqueProductCount => items.length;

  bool get hasMultipleItems => items.length > 1;

  String? get deliveryAddressString {
    if (deliveryAddress == null) return null;

    final address = deliveryAddress!;
    final street = address['street'] ?? '';
    final ward = address['ward'] ?? '';
    final district = address['district'] ?? '';
    final city = address['city'] ?? '';

    return '$street, $ward, $district, $city';
  }

  String? get recipientName => deliveryAddress?['recipientName'];

  String? get recipientPhone => deliveryAddress?['recipientPhone'];

  bool get isOverdue {
    if (estimatedDeliveryDate == null) return false;
    if (isSuccessful || isCancelled) return false;
    return DateTime.now().isAfter(estimatedDeliveryDate!);
  }

  int? get daysUntilDelivery {
    if (estimatedDeliveryDate == null) return null;
    final now = DateTime.now();
    return estimatedDeliveryDate!.difference(now).inDays;
  }

  String get formattedEstimatedDelivery {
    if (estimatedDeliveryDate == null) return 'Chưa xác định';

    final date = estimatedDeliveryDate!;
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedDeliveredAt {
    if (deliveredAt == null) return 'Chưa giao';

    final date = deliveredAt!;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
  }

  int get orderAgeInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  bool get isNewOrder {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  
  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedSubtotal {
    return '${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedDiscountAmount {
    return '${discountAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  String get formattedShippingFee {
    return '${shippingFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  OrderEntity copyWith({
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
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ orderNumber.hashCode;
}
