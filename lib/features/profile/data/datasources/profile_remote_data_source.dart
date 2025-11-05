import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel?> getProfile(String uid);
  Future<void> updateProfile(String uid, Map<String, dynamic> data);
  Future<String> uploadAvatar(String uid, String imagePath);
  Future<void> updatePoints(String uid, int points);
  Future<void> updateOrderStats(
    String uid, {
    int? totalOrders,
    double? totalSpent,
  });
  Stream<UserProfileModel?> watchProfile(String uid);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();

      // Nếu profile không tồn tại, tự động tạo cho user hiện có
      if (!doc.exists) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          // Tạo profile với dữ liệu từ Firebase Auth
          await firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': currentUser.email ?? '',
            'name': currentUser.displayName ?? 'Người dùng',
            'phone': currentUser.phoneNumber ?? '',
            'avatar': currentUser.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'role': 'customer',
            'points': 0,
            'totalOrders': 0,
            'totalSpent': 0.0,
          });

          // Lấy lại profile đã tạo
          final newDoc = await firestore.collection('users').doc(uid).get();
          return UserProfileModel.fromFirestore(newDoc);
        }
        return null;
      }

      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String uid, String imagePath) async {
    try {
      if (kIsWeb) {
        // Web: Chưa hỗ trợ - trả về chuỗi rỗng hoặc throw
        throw UnimplementedError(
          'Avatar upload not supported on web yet. Please use mobile app.',
        );
      }

      final file = File(imagePath);
      final ref = storage.ref().child(
        'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // Cập nhật URL avatar vào profile
      await updateProfile(uid, {'avatar': downloadUrl});

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> updatePoints(String uid, int points) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'points': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update points: $e');
    }
  }

  @override
  Future<void> updateOrderStats(
    String uid, {
    int? totalOrders,
    double? totalSpent,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (totalOrders != null) {
        updateData['totalOrders'] = FieldValue.increment(totalOrders);
      }

      if (totalSpent != null) {
        updateData['totalSpent'] = FieldValue.increment(totalSpent);
      }

      await firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order stats: $e');
    }
  }

  @override
  Stream<UserProfileModel?> watchProfile(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    });
  }
}
