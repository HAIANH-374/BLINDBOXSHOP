class AuthUser {
  final String uid;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  AuthUser copyWith({
    String? uid,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
