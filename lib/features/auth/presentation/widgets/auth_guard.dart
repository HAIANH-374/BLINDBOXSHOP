import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;
  final bool requireAdmin;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = false,
    this.requireAdmin = false,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Kiểm tra yêu cầu xác thực
    if (requireAuth && authState.firebaseUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Kiểm tra yêu cầu quyền admin
    if (requireAdmin) {
      final role = authState.authUser?.role ?? 'customer';
      if (role != 'admin') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    // Nếu đã xác thực và cố truy cập trang login/register, chuyển hướng dựa vào role
    if (authState.firebaseUser != null &&
        (GoRouterState.of(context).uri.path == '/login' ||
            GoRouterState.of(context).uri.path == '/register')) {
      final role = authState.authUser?.role ?? 'customer';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(role == 'admin' ? '/admin' : '/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
