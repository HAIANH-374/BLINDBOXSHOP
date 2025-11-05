import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/notification_utils.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/personal_info_page.dart';
import 'core/presentation/pages/home_page.dart';
import 'features/product/presentation/pages/products_page.dart';
import 'features/product/presentation/pages/product_detail_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/order/presentation/pages/checkout_page.dart';
import 'features/order/presentation/pages/order_history_page.dart';
import 'features/order/presentation/pages/review_page.dart';
import 'features/order/presentation/pages/review_all_products_page.dart';
import 'features/order/presentation/pages/order_detail_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/admin/presentation/pages/admin_product_management_page.dart';
import 'features/admin/presentation/pages/admin_add_product_page.dart';
import 'features/admin/presentation/pages/admin_order_management_page.dart';
import 'features/admin/presentation/pages/admin_customer_management_page.dart';
import 'features/auth/presentation/widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Khởi tạo authProvider bằng cách watch nó
    ref.watch(authProvider);

    return ScreenUtilInit(
      designSize: kIsWeb ? const Size(1920, 1080) : const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: NotificationUtils.scaffoldMessengerKey,
          builder: (context, child) {
            // Thiết kế responsive cho web
            if (kIsWeb) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Tính toán maxWidth dựa trên kích thước màn hình
                  double maxWidth;
                  if (constraints.maxWidth > 1920) {
                    maxWidth = 1920; // Desktop lớn
                  } else if (constraints.maxWidth > 1200) {
                    maxWidth = constraints.maxWidth * 0.9; // Desktop
                  } else if (constraints.maxWidth > 768) {
                    maxWidth = constraints.maxWidth * 0.95; // Tablet
                  } else {
                    maxWidth = constraints.maxWidth; // Mobile
                  }

                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: constraints.maxWidth > 768
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: child,
                    ),
                  );
                },
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}

final _router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    // Lấy trạng thái xác thực
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authProvider);

    if (authState.isLoading) {
      return null;
    }

    if (authState.firebaseUser == null) {
      if (state.uri.path.startsWith('/admin') ||
          state.uri.path.startsWith('/profile') ||
          state.uri.path.startsWith('/cart') ||
          state.uri.path.startsWith('/orders') ||
          state.uri.path.startsWith('/checkout')) {
        return '/login';
      }
    }

    if (authState.firebaseUser != null && state.uri.path.startsWith('/admin')) {
      final role = authState.authUser?.role ?? 'customer';
      if (role != 'admin') {
        return '/home';
      }
    }

    if (authState.firebaseUser != null &&
        (state.uri.path == '/login' || state.uri.path == '/register')) {
      final role = authState.authUser?.role ?? 'customer';
      return role == 'admin' ? '/admin' : '/home';
    }

    return null;
  },
  routes: [
    // Route xác thực
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OTPVerificationPage(
          email: extra?['email'] ?? '',
          type: extra?['type'] ?? 'registration',
          password: extra?['password'],
          newPassword: extra?['newPassword'],
          name: extra?['name'],
          phone: extra?['phone'],
        );
      },
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/product/:id',
      name: 'product-detail',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailPage(
          key: ValueKey<String>(productId),
          productId: productId,
        );
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const ProductsPage(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductsPage(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) =>
          const AuthGuard(requireAuth: true, child: CartPage()),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) =>
          const AuthGuard(requireAuth: true, child: OrderHistoryPage()),
    ),
    GoRoute(
      path: '/order-history',
      name: 'order-history',
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'];
        if (orderId != null && orderId.isNotEmpty) {
          return OrderDetailPage(orderId: orderId);
        }
        return const OrderHistoryPage();
      },
    ),
    GoRoute(
      path: '/review',
      name: 'review',
      builder: (context, state) {
        final productId = state.uri.queryParameters['productId'] ?? '';
        final productName = state.uri.queryParameters['productName'] ?? '';
        final productImage = state.uri.queryParameters['productImage'] ?? '';
        return ReviewPage(
          productId: productId,
          productName: productName,
          productImage: productImage,
        );
      },
    ),
    GoRoute(
      path: '/review-all',
      name: 'review-all',
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'] ?? '';
        return ReviewAllProductsPage(orderId: orderId);
      },
    ),

    // Route trang cá nhân
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) =>
          const AuthGuard(requireAuth: true, child: ProfilePage()),
    ),
    GoRoute(
      path: '/personal-info',
      name: 'personal-info',
      builder: (context, state) => const PersonalInfoPage(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),

    // Route quản trị viên
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AuthGuard(
        requireAuth: true,
        requireAdmin: true,
        child: AdminDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/admin/products',
      name: 'admin-products',
      builder: (context, state) => const AuthGuard(
        requireAuth: true,
        requireAdmin: true,
        child: AdminProductManagementPage(),
      ),
    ),
    GoRoute(
      path: '/admin/products/add',
      name: 'admin-add-product',
      builder: (context, state) => const AuthGuard(
        requireAuth: true,
        requireAdmin: true,
        child: AdminAddProductPage(),
      ),
    ),
    GoRoute(
      path: '/admin/orders',
      name: 'admin-orders',
      builder: (context, state) => const AuthGuard(
        requireAuth: true,
        requireAdmin: true,
        child: AdminOrderManagementPage(),
      ),
    ),
    GoRoute(
      path: '/admin/customers',
      name: 'admin-customers',
      builder: (context, state) => const AuthGuard(
        requireAuth: true,
        requireAdmin: true,
        child: AdminCustomerManagementPage(),
      ),
    ),
  ],
);
