import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Lấy thông tin profile của user
  Future<UserProfile?> getProfile(String uid);

  /// Cập nhật thông tin profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data);

  /// Tải lên avatar và trả về URL
  Future<String> uploadAvatar(String uid, String imagePath);

  /// Cập nhật điểm thưởng
  Future<void> updatePoints(String uid, int points);

  /// Cập nhật thống kê đơn hàng
  Future<void> updateOrderStats(
    String uid, {
    int? totalOrders,
    double? totalSpent,
  });

  /// Lắng nghe thay đổi profile real-time
  Stream<UserProfile?> watchProfile(String uid);
}
