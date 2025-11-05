import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NewProductsSection extends ConsumerWidget {
  const NewProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newProductsAsync = ref.watch(newProductsProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.new_releases,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sản phẩm mới',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.go('/products?type=new');
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: kIsWeb ? 330.h : 300.h,
            child: newProductsAsync.when(
              data: (newProducts) {
                if (newProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có sản phẩm mới',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  itemCount: newProducts.length,
                  itemBuilder: (context, index) {
                    final product = newProducts[index];
                    return Container(
                      width: 170.w,
                      margin: EdgeInsets.only(right: 8.w),
                      child: ProductCard(
                        id: product.id,
                        name: product.name,
                        brand: product.brand,
                        price: product.price,
                        originalPrice: product.originalPrice,
                        image: product.images.isNotEmpty
                            ? product.images.first
                            : '',
                        rating: product.rating,
                        sold: product.sold,
                        reviewCount: product.reviewCount,
                        isFavorite: false,
                        product: product,
                        width: 170.w,
                        margin: 0,
                        onTap: () {
                          context.go('/product/${product.id}');
                        },
                        onAddToCart: () async {
                          final authState = ref.read(authProvider);
                          if (authState.firebaseUser == null) {
                            if (context.mounted) {
                              context.go('/login');
                            }
                            return;
                          }

                          await ref
                              .read(cartProvider.notifier)
                              .addItem(
                                product.id,
                                product.name,
                                product.price,
                                product.images.isNotEmpty
                                    ? product.images.first
                                    : '',
                                quantity: 1,
                                productType: product.productType.name,
                                boxSize: product.boxSize,
                                setSize: product.setSize,
                              );
                        },
                        onToggleFavorite: () {},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Lỗi tải sản phẩm mới: $error',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
