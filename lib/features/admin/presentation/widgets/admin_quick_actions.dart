import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({super.key});

  final List<Map<String, dynamic>> quickActions = const [
    {
      'title': 'Quản lí sản phẩm',
      'icon': Icons.add_box_outlined,
      'color': AppColors.primary,
      'route': '/admin/products',
    },
    {
      'title': 'Quản lý đơn hàng',
      'icon': Icons.receipt_long_outlined,
      'color': AppColors.success,
      'route': '/admin/orders',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 6;
            if (constraints.maxWidth < 600) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth < 900) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth < 1200) {
              crossAxisCount = 5;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.9,
              ),
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return GestureDetector(
                  onTap: () {
                    context.push(action['route']);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: action['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            action['icon'],
                            color: action['color'],
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Flexible(
                          child: Text(
                            action['title'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
