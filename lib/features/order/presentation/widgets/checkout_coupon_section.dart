import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutCouponSection extends StatefulWidget {
  final List<Map<String, dynamic>> availableCoupons;
  final String? selectedCouponCode;
  final Function(String?) onCouponSelected;
  final Function(String) onApplyCouponCode;
  final Function() onRemoveCouponCode;

  const CheckoutCouponSection({
    super.key,
    required this.availableCoupons,
    required this.selectedCouponCode,
    required this.onCouponSelected,
    required this.onApplyCouponCode,
    required this.onRemoveCouponCode,
  });

  @override
  State<CheckoutCouponSection> createState() => _CheckoutCouponSectionState();
}

class _CheckoutCouponSectionState extends State<CheckoutCouponSection> {
  final _couponCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Mã giảm giá',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCodeController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _isLoading ? null : _applyCouponCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Áp dụng',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (widget.availableCoupons.isNotEmpty) ...[
            ...widget.availableCoupons.map(
              (coupon) => _buildCouponItem(context, coupon),
            ),

            SizedBox(height: 12.h),

            if (widget.selectedCouponCode != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onRemoveCouponCode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Bỏ chọn mã giảm giá',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Không có mã giảm giá khả dụng',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponItem(BuildContext context, Map<String, dynamic> coupon) {
    final isSelected = coupon['code'] == widget.selectedCouponCode;
    final isApplicable = _isCouponApplicable(coupon);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : isApplicable
              ? AppColors.success
              : AppColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8.r),
        color: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : isApplicable
            ? AppColors.success.withOpacity(0.05)
            : AppColors.white,
      ),
      child: GestureDetector(
        onTap: isApplicable
            ? () => widget.onCouponSelected(coupon['code'])
            : null,
        child: Row(
          children: [
            Radio<String>(
              value: coupon['code'],
              groupValue: widget.selectedCouponCode,
              onChanged: isApplicable
                  ? (value) => widget.onCouponSelected(value)
                  : null,
              activeColor: AppColors.primary,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coupon['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: coupon['type'] == 'percentage'
                              ? AppColors.primary
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          coupon['formattedValue'] ??
                              (coupon['type'] == 'percentage'
                                  ? '${coupon['value']}%'
                                  : '${coupon['value'].toStringAsFixed(0)} VNĐ'),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    coupon['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  if (coupon['minOrderAmount'] != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Đơn tối thiểu: ${coupon['formattedMinOrderAmount'] ?? '${coupon['minOrderAmount'].toStringAsFixed(0)} VNĐ'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (!isApplicable)
              Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  bool _isCouponApplicable(Map<String, dynamic> coupon) {
    return true;
  }

  Future<void> _applyCouponCode() async {
    final code = _couponCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onApplyCouponCode(code);
      _couponCodeController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    super.dispose();
  }
}
