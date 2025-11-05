enum ProductType {
  single, // Mua đơn lẻ
  box, // Mua theo box
  set, // Mua theo set
  both, // Có thể mua cả đơn lẻ và box/set
}

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final List<String> images;
  final double price;
  final double originalPrice;
  final double discount;
  final int stock;
  final double rating;
  final int reviewCount;
  final int sold;
  final List<String> searchKeywords;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;

  // Tính năng Box/Set
  final ProductType productType;
  final int? boxSize;
  final double? boxPrice;
  final int? setSize;
  final double? setPrice;
  final List<String>? boxContents;
  final List<String>? setContents;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.images,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.sold,
    required this.searchKeywords,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.specifications,
    this.tags,
    required this.productType,
    this.boxSize,
    this.boxPrice,
    this.setSize,
    this.setPrice,
    this.boxContents,
    this.setContents,
  });

  // Các phương thức logic nghiệp vụ

  /// Kiểm tra sản phẩm có đang sale không
  bool get isOnSale => discount > 0;

  /// Giá sau khi giảm
  double get finalPrice => price - discount;

  /// Kiểm tra còn hàng
  bool get isInStock => stock > 0;

  /// Kiểm tra sắp hết hàng
  bool get isLowStock => stock > 0 && stock <= 10;

  /// Kiểm tra hết hàng
  bool get isOutOfStock => stock <= 0;

  /// Định dạng giá
  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Định dạng giá gốc
  String get formattedOriginalPrice {
    return '${originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Phần trăm giảm giá
  String get discountPercentage {
    if (originalPrice == 0) return '0%';
    return '${(discount / originalPrice * 100).round()}%';
  }

  // Box/Set Business Logic

  /// Có thể mua theo box không
  bool get canBuyBox =>
      productType == ProductType.box || productType == ProductType.both;

  /// Có thể mua theo set không
  bool get canBuySet =>
      productType == ProductType.set || productType == ProductType.both;

  /// Có thể mua đơn lẻ không
  bool get canBuySingle =>
      productType == ProductType.single || productType == ProductType.both;

  /// Định dạng giá box
  String get formattedBoxPrice {
    if (boxPrice == null) return '';
    return '${boxPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Định dạng giá set
  String get formattedSetPrice {
    if (setPrice == null) return '';
    return '${setPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Tiết kiệm khi mua box
  double get boxSavings {
    if (boxPrice == null || boxSize == null) return 0.0;
    return (price * boxSize!) - boxPrice!;
  }

  /// Tiết kiệm khi mua set
  double get setSavings {
    if (setPrice == null || setSize == null) return 0.0;
    return (price * setSize!) - setPrice!;
  }

  /// Định dạng tiết kiệm box
  String get formattedBoxSavings {
    if (boxSavings <= 0) return '';
    return '${boxSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Định dạng tiết kiệm set
  String get formattedSetSavings {
    if (setSavings <= 0) return '';
    return '${setSavings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  /// Kiểm tra rating tốt
  bool get hasGoodRating => rating >= 4.0;

  /// Kiểm tra có nhiều đánh giá
  bool get hasManyReviews => reviewCount >= 10;

  /// Kiểm tra sản phẩm phổ biến
  bool get isPopular => sold >= 100;

  /// Kiểm tra sản phẩm mới
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 30; // Mới nếu tạo trong 30 ngày
  }

  /// Kiểm tra sản phẩm trending
  bool get isTrending => isPopular && hasGoodRating;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    List<String>? images,
    double? price,
    double? originalPrice,
    double? discount,
    int? stock,
    double? rating,
    int? reviewCount,
    int? sold,
    List<String>? searchKeywords,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    ProductType? productType,
    int? boxSize,
    double? boxPrice,
    int? setSize,
    double? setPrice,
    List<String>? boxContents,
    List<String>? setContents,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discount: discount ?? this.discount,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sold: sold ?? this.sold,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      productType: productType ?? this.productType,
      boxSize: boxSize ?? this.boxSize,
      boxPrice: boxPrice ?? this.boxPrice,
      setSize: setSize ?? this.setSize,
      setPrice: setPrice ?? this.setPrice,
      boxContents: boxContents ?? this.boxContents,
      setContents: setContents ?? this.setContents,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
