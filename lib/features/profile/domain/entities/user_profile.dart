class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final String email; // Đã thêm: email từ auth
  final String avatar;
  final int points;
  final int totalOrders;
  final double totalSpent;
  final bool isActive; // Đã thêm: trạng thái tài khoản từ auth
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatar,
    required this.points,
    required this.totalOrders,
    required this.totalSpent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasCompletedProfile => name.isNotEmpty && phone.isNotEmpty;
  bool get isVip => totalSpent >= 10000000; // VIP nếu chi tiêu >= 10 triệu

  UserProfile copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    int? points,
    int? totalOrders,
    double? totalSpent,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
