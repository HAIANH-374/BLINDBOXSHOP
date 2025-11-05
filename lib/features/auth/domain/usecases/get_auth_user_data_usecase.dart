import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetAuthUserDataUseCase {
  final AuthRepository repository;

  GetAuthUserDataUseCase(this.repository);

  Future<AuthUser?> call(String uid) async {
    final data = await repository.getAuthUserData(uid);

    if (data == null) {
      return null;
    }

    DateTime createdAt = DateTime.now();
    final createdAtData = data['createdAt'];
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is DateTime) {
      createdAt = createdAtData;
    }

    final authUser = AuthUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
      role: data['role'] as String? ?? 'customer',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
    );

    return authUser;
  }
}
