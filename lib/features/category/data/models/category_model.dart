import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.isActive,
    required super.order,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Chuyển từ Firestore DocumentSnapshot sang Model
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Chuyển từ Map sang Model
  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Chuyển từ Entity sang Model
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Chuyển Model sang Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Chuyển Model sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'image': imageUrl,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  @override
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model cho CategoryStats trong Data Layer
class CategoryStatsModel extends CategoryStatsEntity {
  const CategoryStatsModel({
    required super.totalCategories,
    required super.activeCategories,
    required super.inactiveCategories,
  });

  /// Chuyển từ Map sang Model
  factory CategoryStatsModel.fromMap(Map<String, dynamic> data) {
    return CategoryStatsModel(
      totalCategories: data['totalCategories'] ?? 0,
      activeCategories: data['activeCategories'] ?? 0,
      inactiveCategories: data['inactiveCategories'] ?? 0,
    );
  }

  /// Chuyển Model sang Entity
  CategoryStatsEntity toEntity() {
    return CategoryStatsEntity(
      totalCategories: totalCategories,
      activeCategories: activeCategories,
      inactiveCategories: inactiveCategories,
    );
  }
}
