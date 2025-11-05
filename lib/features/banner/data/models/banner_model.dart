import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/banner_entity.dart';

/// Model cho Banner trong Data Layer
class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imageUrl,
    required super.linkType,
    required super.linkValue,
    required super.isActive,
    required super.order,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['image'] ?? '',
      linkType: data['linkType'] ?? 'none',
      linkValue: data['linkValue'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BannerModel.fromMap(Map<String, dynamic> data) {
    return BannerModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['image'] ?? '',
      linkType: data['linkType'] ?? 'none',
      linkValue: data['linkValue'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      imageUrl: entity.imageUrl,
      linkType: entity.linkType,
      linkValue: entity.linkValue,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      linkType: linkType,
      linkValue: linkValue,
      isActive: isActive,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image': imageUrl,
      'linkType': linkType,
      'linkValue': linkValue,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? linkType,
    String? linkValue,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BannerStatsModel extends BannerStatsEntity {
  const BannerStatsModel({
    required super.totalBanners,
    required super.activeBanners,
    required super.inactiveBanners,
  });

  factory BannerStatsModel.fromMap(Map<String, dynamic> data) {
    return BannerStatsModel(
      totalBanners: data['totalBanners'] ?? 0,
      activeBanners: data['activeBanners'] ?? 0,
      inactiveBanners: data['inactiveBanners'] ?? 0,
    );
  }

  BannerStatsEntity toEntity() {
    return BannerStatsEntity(
      totalBanners: totalBanners,
      activeBanners: activeBanners,
      inactiveBanners: inactiveBanners,
    );
  }
}
