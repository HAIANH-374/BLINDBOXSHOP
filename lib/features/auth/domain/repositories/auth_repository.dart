import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<bool> sendOTPForRegistration(String email);
  Future<bool> sendOTPForPasswordReset(String email);
  Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String type,
  });
  Future<void> clearOTP(String email);

  Future<void> createUserDocument({
    required String uid,
    required String email,
    String? name,
    String? phone,
  });

  Future<Map<String, dynamic>?> getAuthUserData(String uid);
}
