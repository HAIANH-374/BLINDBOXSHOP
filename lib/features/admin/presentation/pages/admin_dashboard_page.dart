import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/admin_recent_orders.dart';
import '../widgets/admin_quick_actions.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

final dashboardDataProvider = FutureProvider.autoDispose((ref) async {
  final stats = await ref.watch(dashboardStatsProvider.future);

  return {
    'totalOrders': stats.totalOrders,
    'totalRevenue': stats.totalRevenue,
    'totalProducts': stats.totalProducts,
    'totalCustomers': stats.totalCustomers,
    'pendingOrders': stats.pendingOrders,
    'lowStockProducts': stats.lowStockProducts,
  };
});

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardDataProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar (tiêu đề và đăng xuất)
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (!mounted) return;
                  context.go('/login');
                },
                tooltip: 'Đăng xuất',
                icon: const Icon(Icons.logout),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final statsAsync = ref.watch(dashboardDataProvider);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: statsAsync.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              orElse: () => SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  children: [
                    // Tổng quan thống kê
                    Builder(
                      builder: (context) {
                        final stats = statsAsync.value!;
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng quan',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16.h),
                              // Lưới thẻ thống kê
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: ResponsiveHelper.getGridColumns(
                                  context,
                                ),
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 1.8,
                                children: [
                                  AdminStatsCard(
                                    title: 'Tổng đơn hàng',
                                    value: stats['totalOrders'].toString(),
                                    icon: Icons.shopping_cart_outlined,
                                    color: AppColors.primary,
                                    trend: '+12%',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Doanh thu',
                                    value:
                                        '${((stats['totalRevenue'] as num) / 1000000).toStringAsFixed(1)}M',
                                    icon: Icons.attach_money,
                                    color: AppColors.success,
                                    trend: '+8%',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Sản phẩm',
                                    value: stats['totalProducts'].toString(),
                                    icon: Icons.inventory_2_outlined,
                                    color: AppColors.info,
                                    trend: '+5',
                                    trendUp: true,
                                  ),
                                  AdminStatsCard(
                                    title: 'Khách hàng',
                                    value: stats['totalCustomers'].toString(),
                                    icon: Icons.people_outline,
                                    color: AppColors.warning,
                                    trend: '+15%',
                                    trendUp: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Hành động nhanh
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AdminQuickActions(),
                    ),

                    SizedBox(height: 16.h),

                    // Đơn hàng gần đây
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AdminRecentOrders(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Thanh điều hướng dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/admin/products');
              break;
            case 2:
              context.push('/admin/orders');
              break;
            case 3:
              context.push('/admin/customers');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Khách hàng',
          ),
        ],
      ),
    );
  }
}
