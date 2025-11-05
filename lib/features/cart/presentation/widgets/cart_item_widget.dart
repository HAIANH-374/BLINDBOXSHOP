import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../product/domain/entities/product_entity.dart';

class CartItemWidget extends StatelessWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final int stock;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelect;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final ProductEntity? product; // Thêm product để lấy dữ liệu stock thực tế

  const CartItemWidget({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.stock,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onQuantityChanged,
    required this.onRemove,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) => onToggleSelect(value ?? false),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            SizedBox(width: 8.w),

            // Hình ảnh sản phẩm
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: AppColors.surfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child:
                    (productImage.startsWith('http') ||
                        productImage.startsWith('https'))
                    ? Image.network(
                        productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          );
                        },
                      )
                    : Image.asset(
                        productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          );
                        },
                      ),
              ),
            ),

            SizedBox(width: 8.w),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Price
                  Text(
                    '${price.toStringAsFixed(0)}₫',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Điều khiển số lượng - Kiểu Shopee gọn
                  Row(
                    children: [
                      // Nhãn số lượng
                      Text(
                        'Số lượng:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(width: 6.w),

                      // Điều khiển số lượng - Gọn
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightGrey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút trừ
                            GestureDetector(
                              onTap: quantity > 1
                                  ? () => onQuantityChanged(quantity - 1)
                                  : null,
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: quantity > 1
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.lightGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4.r),
                                    bottomLeft: Radius.circular(4.r),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 12.sp,
                                  color: quantity > 1
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),

                            // Hiển thị số lượng
                            Container(
                              width: 32.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withOpacity(
                                  0.3,
                                ),
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: AppColors.lightGrey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),

                            // Nút cộng
                            GestureDetector(
                              onTap: quantity < (product?.stock ?? stock)
                                  ? () => onQuantityChanged(quantity + 1)
                                  : null,
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: quantity < (product?.stock ?? stock)
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.lightGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4.r),
                                    bottomRight: Radius.circular(4.r),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 12.sp,
                                  color: quantity < (product?.stock ?? stock)
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Nút xóa
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
