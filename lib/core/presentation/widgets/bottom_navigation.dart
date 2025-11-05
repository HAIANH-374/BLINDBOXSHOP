import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/cart/presentation/providers/cart_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

import '../../constants/app_colors.dart';

class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({super.key});

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Trang chủ',
      'route': '/home',
    },
    {
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view,
      'label': 'Sản phẩm',
      'route': '/products',
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'activeIcon': Icons.shopping_cart,
      'label': 'Giỏ hàng',
      'route': '/cart',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long,
      'label': 'Đơn hàng',
      'route': '/orders',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Tài khoản',
      'route': '/profile',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final route = _navItems[index]['route'];
    if (route != null) {
      if (route == '/cart') {
        final authState = ref.read(authProvider);
        if (authState.firebaseUser == null) {
          context.go('/login');
          return;
        }
      }
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // Có thể dùng tổng số sản phẩm thay vì số loại sản phẩm
    final cartCount = ref.watch(cartItemsCountProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ClipRect(
          child: Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Flexible(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h, // Giảm từ 8 xuống 6
                        horizontal: 0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? item['activeIcon'] : item['icon'],
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 19.sp,
                              ),
                              // Badge cho icon giỏ hàng (chỉ khi đã đăng nhập và count > 0)
                              if (item['route'] == '/cart' &&
                                  authState.firebaseUser != null &&
                                  cartCount > 0)
                                Positioned(
                                  right: -10, // Giảm từ -12 xuống -10
                                  top: -10, // Giảm từ -12 xuống -10
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, // Giảm từ 5 xuống 4
                                      vertical: 1.h, // Giảm từ 2 xuống 1
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(
                                        8.r,
                                      ), // Giảm từ 10 xuống 8
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 14.w, // Giảm từ 16 xuống 14
                                      minHeight: 14.h, // Giảm từ 16 xuống 14
                                    ),
                                    child: Text(
                                      '$cartCount',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 8.sp, // Giảm từ 9 xuống 8
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 1.h), // Giảm từ 2 xuống 1
                          Text(
                            item['label'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 8.sp, // Giảm từ 8.5 xuống 8
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
