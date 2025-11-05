import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.isActive,
    required super.createdAt,
  });

  /// Chuyển đổi từ Firestore document sang AuthUserModel
  factory AuthUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthUserModel.fromMap(data, doc.id);
  }

  /// Chuyển đổi từ Map sang AuthUserModel
  factory AuthUserModel.fromMap(Map<String, dynamic> data, [String? id]) {
    return AuthUserModel(
      uid: id ?? data['uid'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Chuyển đổi sang AuthUser entity
  AuthUser toEntity() {
    return AuthUser(
      uid: uid,
      email: email,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Chuyển đổi từ AuthUser entity
  factory AuthUserModel.fromEntity(AuthUser entity) {
    return AuthUserModel(
      uid: entity.uid,
      email: entity.email,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  /// Chuyển đổi sang Map cho Firebase (chỉ các trường xác thực tối thiểu)
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  AuthUserModel copyWith({
    String? uid,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AuthUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
