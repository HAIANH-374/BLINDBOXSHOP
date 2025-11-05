import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/otp_utils.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();

  Future<Map<String, dynamic>?> getUserProfile(String uid);
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
  });
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);

  Future<void> sendPasswordResetEmail(String email);
  Future<bool> changePassword(String currentPassword, String newPassword);

  Future<bool> sendOTPForRegistration(String email);
  Future<bool> sendOTPForPasswordReset(String email);
  Future<bool> verifyOTP(String email, String otp, String type);
  Future<void> clearOTP(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: $e');
    }
  }

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'avatar': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'customer',
        'points': 0,
        'totalOrders': 0,
        'totalSpent': 0.0,
      });
    } on FirebaseException catch (e) {
      throw Exception('Lỗi tạo hồ sơ người dùng: ${e.message}');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      final updateData = {...data, 'updatedAt': FieldValue.serverTimestamp()};
      await _firestore.collection(_usersCollection).doc(uid).update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi cập nhật thông tin: ${e.message}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<bool> sendOTPForRegistration(String email) async {
    return OTPUtils.sendOTPForRegistration(email);
  }

  @override
  Future<bool> sendOTPForPasswordReset(String email) async {
    return OTPUtils.sendOTPForPasswordReset(email);
  }

  @override
  Future<bool> verifyOTP(String email, String otp, String type) async {
    return OTPUtils.verifyOTP(email, otp, type);
  }

  @override
  Future<void> clearOTP(String email) async {
    await OTPUtils.clearOTP(email);
  }

  // Helper methods
  // Không còn dùng: OTP được tạo bởi OTPUtils

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Không tìm thấy tài khoản với email này');
      case 'wrong-password':
        return Exception('Mật khẩu không chính xác');
      case 'email-already-in-use':
        return Exception('Email đã được sử dụng');
      case 'weak-password':
        return Exception('Mật khẩu quá yếu');
      case 'invalid-email':
        return Exception('Email không hợp lệ');
      case 'user-disabled':
        return Exception('Tài khoản đã bị vô hiệu hóa');
      default:
        return Exception('Lỗi xác thực: ${e.message}');
    }
  }
}
