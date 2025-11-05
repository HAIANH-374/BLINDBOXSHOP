import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';
import '../../../features/product/presentation/widgets/hot_products_section.dart';
import '../../../features/product/presentation/widgets/new_products_section.dart';
import '../widgets/bottom_navigation.dart';
import '../../../features/cart/presentation/providers/cart_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: HomeHeader()),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SearchBarWidget(),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 16.h)),

          SliverList(
            delegate: SliverChildListDelegate([
              const BannerCarousel(),

              SizedBox(height: 24.h),

              const CategoryGrid(),

              SizedBox(height: 24.h),

              const HotProductsSection(),

              SizedBox(height: 24.h),

              const NewProductsSection(),

              SizedBox(height: 100.h),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final authState = ref.watch(authProvider);
          final cartCount = ref.watch(cartItemsCountProvider);
          return FloatingActionButton(
            onPressed: () {
              if (authState.firebaseUser == null) {
                context.go('/login');
              } else {
                context.go('/cart');
              }
            },
            backgroundColor: AppColors.primary,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.white,
                ),
                if (authState.firebaseUser != null && cartCount > 0)
                  Positioned(
                    right: -12,
                    top: -12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.h,
                      ),
                      child: Text(
                        '$cartCount',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
