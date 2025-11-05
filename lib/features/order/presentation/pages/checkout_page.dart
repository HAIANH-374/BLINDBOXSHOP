// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/checkout_payment_section.dart';
import '../widgets/checkout_order_summary.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../../../../core/utils/email_utils.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/models/order_model.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedPaymentMethod = AppConstants.paymentCod;

  List<String> _selectedItemIds = [];

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': AppConstants.paymentCod,
      'name': 'Thanh toán khi nhận hàng',
      'description': 'Thanh toán bằng tiền mặt khi nhận hàng',
      'icon': Icons.money,
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is List<String>) {
      _selectedItemIds = extra;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildAddressSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Icon(Icons.location_on_outlined, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Địa chỉ giao hàng',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              hintText: 'Nhập họ và tên người nhận',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              hintText: 'Nhập số điện thoại',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.length < 10) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Địa chỉ',
              hintText: 'Số nhà, tên đường',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập địa chỉ';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _wardController,
                  decoration: InputDecoration(
                    labelText: 'Phường/Xã',
                    hintText: 'Nhập phường/xã',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập phường/xã';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextFormField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: 'Quận/Huyện',
                    hintText: 'Nhập quận/huyện',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập quận/huyện';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'Tỉnh/Thành phố',
              hintText: 'Nhập tỉnh/thành phố',
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tỉnh/thành phố';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thanh toán',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              context.go('/cart');
            },
            tooltip: 'Giỏ hàng',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Thông tin địa chỉ giao hàng
                    _buildAddressSection(),

                    SizedBox(height: 16.h),

                    // Chọn phương thức thanh toán
                    CheckoutPaymentSection(
                      paymentMethods: paymentMethods,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onPaymentMethodSelected: (methodId) {
                        setState(() {
                          _selectedPaymentMethod = methodId;
                        });
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Ghi chú đơn hàng
                    Container(
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
                          Text(
                            'Ghi chú đơn hàng',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Nhập ghi chú cho đơn hàng (tùy chọn)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Tóm tắt đơn hàng
                    Consumer(
                      builder: (context, ref, child) {
                        final cart = ref.watch(cartProvider);

                        final selectedCartItems = cart.items
                            .where(
                              (item) =>
                                  _selectedItemIds.contains(item.productId),
                            )
                            .map(
                              (item) => {
                                'id': item.productId,
                                'productName': item.productName,
                                'productImage': item.productImage,
                                'price': item.price,
                                'quantity': item.quantity,
                              },
                            )
                            .toList();

                        return CheckoutOrderSummary(items: selectedCartItems);
                      },
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(16.w),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tổng tiền
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_calculateTotal().toStringAsFixed(0)} VNĐ',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Nút đặt hàng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Đặt hàng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    final cart = ref.read(cartProvider);

    final selectedItems = cart.items.where(
      (item) => _selectedItemIds.contains(item.productId),
    );
    double subtotal = selectedItems.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    double shippingFee = subtotal >= 500000 ? 0 : 30000;

    return subtotal + shippingFee;
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = ref.read(authProvider);
      final uid = auth.firebaseUser?.uid;
      if (uid == null) {
        throw Exception('Bạn cần đăng nhập để đặt hàng');
      }

      final cart = ref.read(cartProvider);
      if (cart.items.isEmpty) {
        throw Exception('Giỏ hàng trống');
      }

      final selectedCartItems = cart.items
          .where((item) => _selectedItemIds.contains(item.productId))
          .toList();
      if (selectedCartItems.isEmpty) {
        throw Exception('Không có sản phẩm nào được chọn');
      }

      final orderItems = selectedCartItems
          .map(
            (cartItem) => OrderItem(
              productId: cartItem.productId,
              productName: cartItem.productName,
              productImage: cartItem.productImage,
              price: cartItem.price,
              quantity: cartItem.quantity,
              orderType: OrderType.single,
              totalPrice: cartItem.price * cartItem.quantity,
            ),
          )
          .toList();

      final orderTotal = _calculateTotal();
      final shipping = orderTotal >= 500000 ? 0.0 : 30000.0;

      final order = OrderModel(
        id: '',
        userId: uid,
        orderNumber: '',
        items: orderItems,
        subtotal: orderTotal - shipping,
        discountAmount: 0.0,
        shippingFee: shipping,
        totalAmount: orderTotal,
        status: OrderStatus.pending,
        deliveryAddressId: '',
        deliveryAddress: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'ward': _wardController.text.trim(),
          'district': _districtController.text.trim(),
          'city': _cityController.text.trim(),
          'note': '',
        },
        paymentMethodId: _selectedPaymentMethod,
        paymentMethodName: paymentMethods.firstWhere(
          (p) => p['id'] == _selectedPaymentMethod,
          orElse: () => {'name': 'Thanh toán khi nhận hàng'},
        )['name'],
        discountCode: null,
        note: _noteController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(ordersProvider.notifier).createOrder(order);
      final createdOrder = ref.read(ordersProvider).first;

      for (final itemId in _selectedItemIds) {
        await ref.read(cartProvider.notifier).removeItem(itemId);
      }

      try {
        final email = auth.firebaseUser?.email ?? '';
        final userName = auth.firebaseUser?.displayName ?? 'Khách hàng';
        if (email.isNotEmpty) {
          await EmailUtils.sendOrderNotificationEmail(
            userEmail: email,
            order: OrderModel.fromEntity(createdOrder),
            userName: userName,
          );
        }
      } catch (e) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công! Đơn hàng đang được xử lý.'),
            backgroundColor: AppColors.success,
          ),
        );

        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
