import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<User?> authStateChanges() => remoteDataSource.authStateChanges;

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await remoteDataSource.signInWithEmailAndPassword(
      email,
      password,
    );
    return cred?.user?.uid;
  }

  @override
  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await remoteDataSource.createUserWithEmailAndPassword(
      email,
      password,
    );
    return cred?.user?.uid;
  }

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  Future<void> createUserDocument({
    required String uid,
    required String email,
    String? name,
    String? phone,
  }) async {
    await remoteDataSource.createUserProfile(
      uid: uid,
      email: email,
      name: name ?? '',
      phone: phone,
    );
  }

  @override
  Future<Map<String, dynamic>?> getAuthUserData(String uid) async {
    final userData = await remoteDataSource.getUserProfile(uid);

    if (userData == null) {
      return null;
    }

    // Return only auth-related fields
    return {
      'uid': userData['uid'],
      'email': userData['email'],
      'role': userData['role'] ?? 'customer',
      'isActive': userData['isActive'] ?? true,
      'createdAt': userData['createdAt'],
    };
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return remoteDataSource.changePassword(currentPassword, newPassword);
  }

  // OTP flows
  @override
  Future<bool> sendOTPForRegistration(String email) {
    return remoteDataSource.sendOTPForRegistration(email);
  }

  @override
  Future<bool> sendOTPForPasswordReset(String email) {
    return remoteDataSource.sendOTPForPasswordReset(email);
  }

  @override
  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  }) {
    return remoteDataSource.verifyOTP(email, otp, type);
  }

  @override
  Future<void> clearOTP(String email) {
    return remoteDataSource.clearOTP(email);
  }
}
