import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.name,
    required super.phone,
    required super.email,
    required super.avatar,
    required super.points,
    required super.totalOrders,
    required super.totalSpent,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      avatar: data['avatar'] ?? '',
      points: data['points'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      avatar: entity.avatar,
      points: entity.points,
      totalOrders: entity.totalOrders,
      totalSpent: entity.totalSpent,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'points': points,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'points': points,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
