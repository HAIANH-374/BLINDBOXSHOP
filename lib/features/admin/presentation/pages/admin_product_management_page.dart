// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../product/data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/export_utils.dart';
import '../../../../core/utils/notification_utils.dart';

class AdminProductManagementPage extends ConsumerStatefulWidget {
  const AdminProductManagementPage({super.key});

  @override
  ConsumerState<AdminProductManagementPage> createState() =>
      _AdminProductManagementPageState();
}

final adminProductsProvider = StreamProvider.autoDispose<List<ProductModel>>((
  ref,
) {
  final query = FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true);
  return query.snapshots().map(
    (snap) => snap.docs.map((d) => ProductModel.fromFirestore(d)).toList(),
  );
});

final productCategoriesProvider = StreamProvider.autoDispose<List<String>>((
  ref,
) {
  return FirebaseFirestore.instance.collection('products').snapshots().map((
    snap,
  ) {
    final categories = <String>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final category = (data['category'] ?? '').toString();
      if (category.isNotEmpty) categories.add(category);
    }
    final list = categories.toList()..sort();
    return list;
  });
});

class _AdminProductManagementPageState
    extends ConsumerState<AdminProductManagementPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Mới nhất';

  final List<String> _categories = [
    'Tất cả',
    'Bb3',
    'Labubu',
    'Hirono',
    'Pop Mart',
    'Sonny Angel',
    'Molly',
  ];
  final List<String> _sortOptions = [
    'Mới nhất',
    'Tên A-Z',
    'Tên Z-A',
    'Giá thấp-cao',
    'Giá cao-thấp',
    'Bán chạy',
  ];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final dynamicCategories = categoriesAsync.maybeWhen(
      data: (cats) => ['Tất cả', ...cats],
      orElse: () => _categories,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar (tiêu đề và hành động)
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Quản lý sản phẩm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Ô tìm kiếm và bộ lọc nhanh
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  // Ô tìm kiếm sản phẩm
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      // Mở bộ lọc
                      icon: const Icon(Icons.filter_list),
                      onPressed: () =>
                          _showFilterBottomSheet(dynamicCategories),
                    ),
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
                          children: [
                            // Chip danh mục
                            _buildFilterChip('Danh mục', _selectedCategory),
                            SizedBox(width: 8.w),
                            // Chip sắp xếp
                            _buildFilterChip('Sắp xếp', _sortBy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final productsAsync = ref.watch(adminProductsProvider);
                return productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi tải sản phẩm: $e')),
                  data: (products) {
                    final filtered = products.where((product) {
                      if (_searchQuery.isNotEmpty) {
                        final name = product.name.toLowerCase();
                        if (!name.contains(_searchQuery.toLowerCase())) {
                          return false;
                        }
                      }

                      if (_selectedCategory != 'Tất cả' &&
                          product.category != _selectedCategory)
                        return false;

                      return true;
                    }).toList();

                    switch (_sortBy) {
                      case 'Mới nhất':
                        filtered.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );
                        break;
                      case 'Tên A-Z':
                        filtered.sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                            b.name.toLowerCase(),
                          ),
                        );
                        break;
                      case 'Tên Z-A':
                        filtered.sort(
                          (a, b) => b.name.toLowerCase().compareTo(
                            a.name.toLowerCase(),
                          ),
                        );
                        break;
                      case 'Giá thấp-cao':
                        filtered.sort((a, b) => a.price.compareTo(b.price));
                        break;
                      case 'Giá cao-thấp':
                        filtered.sort((a, b) => b.price.compareTo(a.price));
                        break;
                      case 'Bán chạy':
                        filtered.sort((a, b) => b.sold.compareTo(a.sold));
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
                                Icons.inventory_2_outlined,
                                size: 60.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không có sản phẩm',
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
                        final product = filtered[index];
                        // Mục sản phẩm (ảnh, thông tin, giá, đánh giá, tồn)
                        return _buildProductItem(product);
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
      onTap: () {
        final categories = ref
            .read(productCategoriesProvider)
            .maybeWhen(
              data: (cats) => ['Tất cả', ...cats],
              orElse: () => _categories,
            );
        _showFilterBottomSheet(categories);
      },
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

  Widget _buildProductItem(ProductModel product) {
    final stock = product.stock;
    final isOutOfStock = stock <= 0;

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
        // Ảnh sản phẩm + nhãn MỚI
        contentPadding: EdgeInsets.all(16.w),
        leading: SizedBox(
          width: 60.w,
          height: 60.w,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  product.images.isNotEmpty
                      ? product.images.first
                      : 'https://via.placeholder.com/100x100',
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              if (product.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 7)),
              ))
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'MỚI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Tên sản phẩm
        title: Text(
          product.name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        // Thông tin phụ (thương hiệu, danh mục, giá, đánh giá, tồn)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              '${product.brand} • ${product.category}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              'Ảnh: ${product.images.isNotEmpty ? product.images.first : "Chưa có"}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${product.originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.star, size: 16.sp, color: Colors.amber),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    '${product.rating} (${product.sold} đã bán)',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isOutOfStock ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isOutOfStock ? 'Hết hàng' : 'Còn ${product.stock}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Menu hành động
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleProductAction(value, product),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy_image_url',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy đường dẫn ảnh'),
                ],
              ),
            ),
            PopupMenuItem(
              value: product.isActive ? 'hide' : 'show',
              child: Row(
                children: [
                  Icon(
                    product.isActive ? Icons.visibility_off : Icons.visibility,
                  ),
                  const SizedBox(width: 8),
                  Text(product.isActive ? 'Ẩn sản phẩm' : 'Hiện sản phẩm'),
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

  void _showAddProductDialog() {
    context.go('/admin/products/add');
  }

  void _showFilterBottomSheet(List<String> categories) {
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
                          _selectedCategory = 'Tất cả';
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
                      // Chọn danh mục
                      _buildFilterSection(
                        'Danh mục',
                        categories,
                        _selectedCategory,
                        (value) {
                          setModalState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
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
                          setState(
                            () {},
                          ); // Xây dựng lại với các bộ lọc đã chọn
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

  void _handleProductAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(product);
        break;
      case 'copy_image_url':
        _copyImageUrl(product);
        break;
      case 'hide':
      case 'show':
        _toggleProductVisibility(product);
        break;
      case 'delete':
        _showDeleteDialog(product);
        break;
    }
  }

  void _copyImageUrl(ProductModel product) async {
    if (product.images.isEmpty) {
      NotificationUtils.showError('Sản phẩm chưa có ảnh');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: product.images.first));
      NotificationUtils.showSuccess('Đã copy đường dẫn ảnh');
    } catch (e) {
      NotificationUtils.showError('Lỗi copy: $e');
    }
  }

  void _showEditProductDialog(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final brandController = TextEditingController(text: product.brand);
    final categoryController = TextEditingController(text: product.category);
    final imageController = TextEditingController(
      text: product.images.isNotEmpty ? product.images.first : '',
    );
    final priceController = TextEditingController(
      text: product.price.toStringAsFixed(0),
    );
    final originalPriceController = TextEditingController(
      text: product.originalPrice.toStringAsFixed(0),
    );
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );
    bool isActive = product.isActive;

    final categoriesAsync = ref.read(productCategoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (cats) => cats,
      orElse: () => <String>[],
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          title: Text('Chỉnh sửa sản phẩm'),
          content: SizedBox(
            width: 380.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Thương hiệu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Danh mục: cho phép chọn từ danh sách hoặc nhập mới
                  DropdownButtonFormField<String>(
                    value: categories.contains(categoryController.text)
                        ? categoryController.text
                        : null,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        categoryController.text = val ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Danh mục (chọn)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục (hoặc nhập mới)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: 'Ảnh (URL)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá bán',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: originalPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá gốc',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tồn kho',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kích hoạt'),
                    value: isActive,
                    onChanged: (v) => setModalState(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Xác thực
                final name = nameController.text.trim();
                final brand = brandController.text.trim();
                final category = categoryController.text.trim();
                final image = imageController.text.trim();
                final price = double.tryParse(priceController.text.trim());
                final original = double.tryParse(
                  originalPriceController.text.trim(),
                );
                final stock = int.tryParse(stockController.text.trim());

                if (name.isEmpty || brand.isEmpty || category.isEmpty) {
                  NotificationUtils.showError('Vui lòng nhập đầy đủ thông tin');
                  return;
                }
                if (price == null || original == null || stock == null) {
                  NotificationUtils.showError('Giá/Tồn kho không hợp lệ');
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(product.id)
                      .update({
                        'name': name,
                        'brand': brand,
                        'category': category,
                        'images': image.isNotEmpty
                            ? [image]
                            : product.images, // giữ ảnh cũ nếu không có ảnh mới
                        'price': price,
                        'originalPrice': original,
                        'stock': stock,
                        'isActive': isActive,
                        'updatedAt': DateTime.now(),
                      });

                  if (mounted) {
                    Navigator.pop(context);
                  }
                  NotificationUtils.showSuccess('Đã cập nhật sản phẩm');
                } catch (e) {
                  NotificationUtils.showError('Lỗi cập nhật: $e');
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleProductVisibility(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'isActive': !product.isActive});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.isActive ? 'Đã ẩn sản phẩm' : 'Đã hiện sản phẩm',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showDeleteDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?'),
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
                    .collection('products')
                    .doc(product.id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa sản phẩm')),
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

  void _exportToExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang xuất dữ liệu sản phẩm...'),
          backgroundColor: AppColors.primary,
        ),
      );

      await ExportUtils.exportProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xuất dữ liệu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
