// ignore_for_file: unused_element, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../../core/constants/app_colors.dart';

class AdminCustomerManagementPage extends ConsumerStatefulWidget {
  const AdminCustomerManagementPage({super.key});

  @override
  ConsumerState<AdminCustomerManagementPage> createState() =>
      _AdminCustomerManagementPageState();
}

final adminCustomersProvider =
    StreamProvider.autoDispose<List<UserProfileModel>>((ref) {
      final query = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .orderBy('createdAt', descending: true);
      return query.snapshots().map(
        (snap) =>
            snap.docs.map((d) => UserProfileModel.fromFirestore(d)).toList(),
      );
    });

class _AdminCustomerManagementPageState
    extends ConsumerState<AdminCustomerManagementPage> {
  String _selectedTab = 'Tất cả';
  String _searchQuery = '';

  String _sortBy = 'Mới nhất';

  final List<String> _tabs = ['Tất cả', 'Hoạt động', 'Bị khóa', 'VIP'];

  final List<String> _sortOptions = [
    'Mới nhất',
    'Cũ nhất',
    'Mua nhiều nhất',
    'Chi tiêu cao nhất',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar (tiêu đề và lọc)
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Quản lý khách hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Ô tìm kiếm và chip lọc nhanh
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  // Tìm kiếm khách hàng
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm khách hàng...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [_buildFilterChip('Sắp xếp', _sortBy)],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabs ngang
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = tab == _selectedTab;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[600],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final customersAsync = ref.watch(adminCustomersProvider);
                return customersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Lỗi tải khách hàng: $e')),
                  data: (customers) {
                    final filtered = customers.where((customer) {
                      // Tab filter
                      if (_selectedTab == 'Hoạt động' && !customer.isActive)
                        return false;
                      if (_selectedTab == 'Bị khóa' && customer.isActive)
                        return false;
                      if (_selectedTab == 'VIP' &&
                          customer.totalSpent < 1000000)
                        return false; // VIP threshold

                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final name = customer.name.toLowerCase();
                        final email = customer.email.toLowerCase();
                        final phone = customer.phone.toLowerCase();
                        if (!name.contains(_searchQuery.toLowerCase()) &&
                            !email.contains(_searchQuery.toLowerCase()) &&
                            !phone.contains(_searchQuery.toLowerCase())) {
                          return false;
                        }
                      }

                      // Trạng thái được xử lý bởi tabs
                      if (_selectedTab == 'Hoạt động' && !customer.isActive)
                        return false;
                      if (_selectedTab == 'Bị khóa' && customer.isActive)
                        return false;
                      if (_selectedTab == 'VIP' &&
                          customer.totalSpent < 1000000)
                        return false;

                      return true;
                    }).toList();

                    switch (_sortBy) {
                      case 'Mới nhất':
                        filtered.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );
                        break;
                      case 'Cũ nhất':
                        filtered.sort(
                          (a, b) => a.createdAt.compareTo(b.createdAt),
                        );
                        break;
                      case 'Mua nhiều nhất':
                        filtered.sort(
                          (a, b) => (b.totalOrders).compareTo(a.totalOrders),
                        );
                        break;
                      case 'Chi tiêu cao nhất':
                        filtered.sort(
                          (a, b) => (b.totalSpent).compareTo(a.totalSpent),
                        );
                        break;
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không có khách hàng',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        // Mục khách hàng (avatar, trạng thái, chỉ số, hành động)
                        return _buildCustomerItem(customer);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerItem(UserProfileModel customer) {
    final status = customer.isActive ? 'active' : 'locked';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusDisplayName(status);
    final isVip = customer.totalSpent >= 1000000; // VIP threshold

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundImage: customer.avatar.isNotEmpty
                  ? NetworkImage(customer.avatar)
                  : null,
              child: customer.avatar.isEmpty
                  ? Icon(Icons.person, size: 30.sp, color: Colors.grey[400])
                  : null,
            ),
            if (isVip)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.star, size: 12.sp, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              customer.email,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 4.h),
            Text(
              customer.phone,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                Icon(Icons.shopping_bag, size: 16.sp, color: Colors.grey[600]),
                Text(
                  '${customer.totalOrders} đơn hàng',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 8.w),
                Icon(Icons.attach_money, size: 16.sp, color: Colors.grey[600]),
                Text(
                  '${customer.totalSpent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                Icon(Icons.star, size: 16.sp, color: Colors.amber),
                Text(
                  '${customer.points} điểm',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                Text(
                  'Tham gia ${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCustomerAction(value, customer),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Xem chi tiết'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'orders',
              child: Row(
                children: [
                  Icon(Icons.shopping_bag),
                  SizedBox(width: 8),
                  Text('Đơn hàng'),
                ],
              ),
            ),
            PopupMenuItem(
              value: customer.isActive ? 'lock' : 'unlock',
              child: Row(
                children: [
                  Icon(customer.isActive ? Icons.lock : Icons.lock_open),
                  const SizedBox(width: 8),
                  Text(customer.isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'locked':
        return Colors.red;
      case 'vip':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'locked':
        return 'Bị khóa';
      case 'vip':
        return 'VIP';
      default:
        return status;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Tiêu đề bộ lọc + nút đặt lại
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _sortBy = 'Mới nhất';
                        });
                      },
                      child: Text(
                        'Đặt lại',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chọn sắp xếp
                      _buildFilterSection('Sắp xếp', _sortOptions, _sortBy, (
                        value,
                      ) {
                        setModalState(() {
                          _sortBy = value;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              // Nút hủy/áp dụng
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Áp dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleCustomerAction(String action, UserProfileModel customer) {
    switch (action) {
      case 'view':
        _viewCustomerDetails(customer);
        break;
      case 'orders':
        _viewCustomerOrders(customer);
        break;
      case 'lock':
      case 'unlock':
        _toggleCustomerLock(customer);
        break;
      case 'delete':
        _showDeleteDialog(customer);
        break;
    }
  }

  void _viewCustomerDetails(UserProfileModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết khách hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${customer.name}'),
            SizedBox(height: 6.h),
            Text('Email: ${customer.email}'),
            SizedBox(height: 6.h),
            Text('SĐT: ${customer.phone}'),
            SizedBox(height: 6.h),
            Text('Tổng đơn hàng: ${customer.totalOrders}'),
            SizedBox(height: 6.h),
            Text('Tổng chi tiêu: ${customer.totalSpent.toStringAsFixed(0)}đ'),
            SizedBox(height: 6.h),
            Text('Điểm: ${customer.points}'),
            SizedBox(height: 6.h),
            Text('Trạng thái: ${customer.isActive ? 'Hoạt động' : 'Bị khóa'}'),
            SizedBox(height: 6.h),
            Text(
              'Tham gia: ${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _viewCustomerOrders(UserProfileModel customer) {
    GoRouter.of(context).push('/admin/orders?userId=${customer.uid}');
  }

  void _toggleCustomerLock(UserProfileModel customer) {
    final isLocked = !customer.isActive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
        content: Text(
          isLocked
              ? 'Bạn có chắc chắn muốn mở khóa tài khoản của ${customer.name}?'
              : 'Bạn có chắc chắn muốn khóa tài khoản của ${customer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(customer.uid)
                    .update({'isActive': !customer.isActive});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isLocked ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            child: Text(isLocked ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserProfileModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa khách hàng'),
        content: Text('Bạn có chắc chắn muốn xóa khách hàng ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(customer.uid)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa khách hàng')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // all actions implemented
}
