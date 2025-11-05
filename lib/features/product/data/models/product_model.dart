import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

export '../../domain/entities/product_entity.dart' show ProductType;

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.brand,
    required super.images,
    required super.price,
    required super.originalPrice,
    required super.discount,
    required super.stock,
    required super.rating,
    required super.reviewCount,
    required super.sold,
    required super.searchKeywords,
    required super.isActive,
    required super.isFeatured,
    required super.createdAt,
    required super.updatedAt,
    super.specifications,
    super.tags,
    required super.productType,
    super.boxSize,
    super.boxPrice,
    super.setSize,
    super.setPrice,
    super.boxContents,
    super.setContents,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      sold: data['sold'] ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      productType: ProductType.values.firstWhere(
        (e) => e.name == data['productType'],
        orElse: () => ProductType.single,
      ),
      boxSize: data['boxSize'],
      boxPrice: data['boxPrice']?.toDouble(),
      setSize: data['setSize'],
      setPrice: data['setPrice']?.toDouble(),
      boxContents: data['boxContents'] != null
          ? List<String>.from(data['boxContents'])
          : null,
      setContents: data['setContents'] != null
          ? List<String>.from(data['setContents'])
          : null,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      sold: data['sold'] ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      productType: ProductType.values.firstWhere(
        (e) => e.name == data['productType'],
        orElse: () => ProductType.single,
      ),
      boxSize: data['boxSize'],
      boxPrice: data['boxPrice']?.toDouble(),
      setSize: data['setSize'],
      setPrice: data['setPrice']?.toDouble(),
      boxContents: data['boxContents'] != null
          ? List<String>.from(data['boxContents'])
          : null,
      setContents: data['setContents'] != null
          ? List<String>.from(data['setContents'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'images': images,
      'price': price,
      'originalPrice': originalPrice,
      'discount': discount,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'sold': sold,
      'searchKeywords': searchKeywords,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'specifications': specifications,
      'tags': tags,
      'productType': productType.name,
      'boxSize': boxSize,
      'boxPrice': boxPrice,
      'setSize': setSize,
      'setPrice': setPrice,
      'boxContents': boxContents,
      'setContents': setContents,
    };
  }

  @override
  ProductModel copyWith({
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
    return ProductModel(
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

  ProductEntity toEntity() => this;

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      brand: entity.brand,
      images: entity.images,
      price: entity.price,
      originalPrice: entity.originalPrice,
      discount: entity.discount,
      stock: entity.stock,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      sold: entity.sold,
      searchKeywords: entity.searchKeywords,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      specifications: entity.specifications,
      tags: entity.tags,
      productType: entity.productType,
      boxSize: entity.boxSize,
      boxPrice: entity.boxPrice,
      setSize: entity.setSize,
      setPrice: entity.setPrice,
      boxContents: entity.boxContents,
      setContents: entity.setContents,
    );
  }
}
