import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile?> getProfile(String uid) async {
    try {
      return await remoteDataSource.getProfile(uid);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateProfile(uid, data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String uid, String imagePath) async {
    try {
      return await remoteDataSource.uploadAvatar(uid, imagePath);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> updatePoints(String uid, int points) async {
    try {
      await remoteDataSource.updatePoints(uid, points);
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
      await remoteDataSource.updateOrderStats(
        uid,
        totalOrders: totalOrders,
        totalSpent: totalSpent,
      );
    } catch (e) {
      throw Exception('Failed to update order stats: $e');
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    try {
      return remoteDataSource.watchProfile(uid);
    } catch (e) {
      throw Exception('Failed to watch profile: $e');
    }
  }
}
