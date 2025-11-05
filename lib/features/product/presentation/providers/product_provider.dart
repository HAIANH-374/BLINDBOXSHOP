import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/notification_utils.dart';
import '../../domain/entities/product_entity.dart';
import 'product_di.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductEntity>>((ref) {
      return ProductsNotifier(ref);
    });

final featuredProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  try {
    final useCase = ref.read(getFeaturedProductsUseCaseProvider);
    return await useCase.call();
  } catch (e) {
    NotificationUtils.showError('Lỗi tải sản phẩm nổi bật: ${e.toString()}');
    return [];
  }
});

// Provider sản phẩm mới - Clean Architecture: sử dụng UseCase
final newProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  try {
    final useCase = ref.read(getNewProductsUseCaseProvider);
    return await useCase.call();
  } catch (e) {
    NotificationUtils.showError('Lỗi tải sản phẩm mới: ${e.toString()}');
    return [];
  }
});

// Provider sản phẩm hot - Clean Architecture: sử dụng UseCase
final hotProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  try {
    final useCase = ref.read(getHotProductsUseCaseProvider);
    return await useCase.call();
  } catch (e) {
    NotificationUtils.showError('Lỗi tải sản phẩm bán chạy: ${e.toString()}');
    return [];
  }
});

// Provider sản phẩm theo id - Clean Architecture: sử dụng UseCase
final productByIdProvider = FutureProvider.family<ProductEntity?, String>((
  ref,
  productId,
) async {
  try {
    final useCase = ref.read(getProductByIdUseCaseProvider);
    return await useCase.call(productId);
  } catch (e) {
    NotificationUtils.showError('Lỗi tải sản phẩm: ${e.toString()}');
    return null;
  }
});

// Provider sản phẩm liên quan theo danh mục - Clean Architecture: sử dụng UseCase
final relatedProductsByCategoryProvider =
    FutureProvider.family<List<ProductEntity>, String>((ref, category) async {
      try {
        final useCase = ref.read(getProductsByCategoryUseCaseProvider);
        return await useCase.call(category, limit: 8);
      } catch (e) {
        NotificationUtils.showError(
          'Lỗi tải sản phẩm liên quan: ${e.toString()}',
        );
        return [];
      }
    });

// Provider sản phẩm theo danh mục
final productsByCategoryProvider = Provider.family<List<ProductEntity>, String>(
  (ref, category) {
    final products = ref.watch(productsProvider);
    if (category == 'Tất cả') {
      return products;
    }
    return products.where((product) => product.category == category).toList();
  },
);

// Provider sản phẩm theo thương hiệu
final productsByBrandProvider = Provider.family<List<ProductEntity>, String>((
  ref,
  brand,
) {
  final products = ref.watch(productsProvider);
  if (brand == 'Tất cả') {
    return products;
  }
  return products.where((product) => product.brand == brand).toList();
});

// Provider kết quả tìm kiếm
final searchResultsProvider =
    StateNotifierProvider<SearchNotifier, List<ProductEntity>>((ref) {
      return SearchNotifier(ref);
    });

// Provider chi tiết sản phẩm
final productDetailProvider =
    StateNotifierProvider<ProductDetailNotifier, ProductEntity?>((ref) {
      return ProductDetailNotifier(ref);
    });

// Provider thương hiệu (local) - lấy danh sách thương hiệu từ sản phẩm
final localBrandsProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productsProvider);
  final brands = products.map((product) => product.brand).toSet().toList();
  brands.sort();
  return ['Tất cả', ...brands];
});

class ProductsNotifier extends StateNotifier<List<ProductEntity>> {
  final Ref ref;
  ProductsNotifier(this.ref) : super([]);

  /// Tải tất cả sản phẩm - Clean Architecture: uses UseCase
  Future<void> loadProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) async {
    try {
      final useCase = ref.read(getProductsUseCaseProvider);
      final products = await useCase.call(
        category: category,
        brand: brand,
        isActive: isActive,
        isFeatured: isFeatured,
        limit: limit,
      );
      state = products;
    } catch (e) {
      NotificationUtils.showError(
        'Lỗi tải danh sách sản phẩm: ${e.toString()}',
      );
    }
  }

  /// Tìm kiếm sản phẩm - Clean Architecture: uses UseCase
  Future<void> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    try {
      final useCase = ref.read(searchProductsUseCaseProvider);
      final products = await useCase.call(
        query,
        category: category,
        brand: brand,
        limit: limit,
      );
      state = products;
    } catch (e) {
      NotificationUtils.showError('Lỗi tìm kiếm sản phẩm: ${e.toString()}');
    }
  }

  /// Tạo sản phẩm mới
  Future<void> addProduct(ProductEntity product) async {
    try {
      final useCase = ref.read(createProductUseCaseProvider);
      final createdProduct = await useCase.call(product);
      state = [createdProduct, ...state];
      NotificationUtils.showSuccess('Thêm sản phẩm thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi thêm sản phẩm: ${e.toString()}');
    }
  }

  /// Cập nhật sản phẩm
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final useCase = ref.read(updateProductUseCaseProvider);
      await useCase.call(product);

      // Cập nhật local state
      final index = state.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final updatedProducts = List<ProductEntity>.from(state);
        updatedProducts[index] = product;
        state = updatedProducts;
      }

      NotificationUtils.showSuccess('Cập nhật sản phẩm thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  /// Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      final useCase = ref.read(deleteProductUseCaseProvider);
      await useCase.call(productId);

      // Cập nhật local state
      state = state.where((p) => p.id != productId).toList();

      NotificationUtils.showSuccess('Xóa sản phẩm thành công!');
    } catch (e) {
      NotificationUtils.showError('Lỗi xóa sản phẩm: ${e.toString()}');
    }
  }

  // Các thao tác stock đã chuyển sang feature Inventory (tuân thủ SRP)
  // Sử dụng InventoryProvider cho tất cả thao tác quản lý stock
  // Các phương thức này đã lỗi thời và sẽ bị xóa
  @Deprecated('Use InventoryProvider.updateStock instead')
  Future<void> updateStock(String productId, int newStock) async {
    throw UnimplementedError(
      'Stock operations moved to Inventory feature. '
      'Use InventoryProvider.updateStock instead.',
    );
  }

  @Deprecated('Use InventoryProvider.updateStock with isIncrease=false instead')
  Future<void> decreaseStock(String productId, int quantity) async {
    throw UnimplementedError(
      'Stock operations moved to Inventory feature. '
      'Use InventoryProvider.updateStock(productId, quantity, isIncrease: false) instead.',
    );
  }

  @Deprecated('Use InventoryProvider.updateStock with isIncrease=true instead')
  Future<void> increaseStock(String productId, int quantity) async {
    throw UnimplementedError(
      'Stock operations moved to Inventory feature. '
      'Use InventoryProvider.updateStock(productId, quantity, isIncrease: true) instead.',
    );
  }

  /// Lấy sản phẩm theo ID (local)
  ProductEntity? getProductById(String productId) {
    try {
      return state.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  @Deprecated('Use InventoryProvider.checkStock instead')
  Future<bool> checkStock(String productId, int quantity) async {
    throw UnimplementedError(
      'Stock operations moved to Inventory feature. '
      'Use InventoryProvider.checkStock instead.',
    );
  }
}

class SearchNotifier extends StateNotifier<List<ProductEntity>> {
  final Ref ref;
  SearchNotifier(this.ref) : super([]);

  Future<void> searchProducts(
    String query, {
    String? category,
    String? brand,
  }) async {
    try {
      final results = await ref
          .read(productRepositoryProvider)
          .searchProducts(query, category: category, brand: brand);
      state = results;
    } catch (e) {
      NotificationUtils.showError('Lỗi tìm kiếm sản phẩm: ${e.toString()}');
      state = [];
    }
  }

  void clearSearch() {
    state = [];
  }
}

class ProductDetailNotifier extends StateNotifier<ProductEntity?> {
  final Ref ref;
  ProductDetailNotifier(this.ref) : super(null);

  Future<void> loadProduct(String productId) async {
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .getProductById(productId);
      state = product;
    } catch (e) {
      NotificationUtils.showError('Lỗi tải sản phẩm: ${e.toString()}');
      state = null;
    }
  }

  void clearProduct() {
    state = null;
  }
}

// Stream providers cho cập nhật real-time
final productStreamProvider = StreamProvider.family<ProductEntity?, String>((
  ref,
  productId,
) {
  return ref.read(productRepositoryProvider).watchProduct(productId);
});

final productsStreamProvider =
    StreamProvider.family<List<ProductEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      return ref
          .read(productRepositoryProvider)
          .watchProducts(
            category: params['category'] as String?,
            brand: params['brand'] as String?,
            isActive: params['isActive'] as bool?,
            isFeatured: params['isFeatured'] as bool?,
            limit: params['limit'] as int?,
          );
    });

final featuredProductsStreamProvider = StreamProvider<List<ProductEntity>>((
  ref,
) {
  return ref.read(productRepositoryProvider).watchFeaturedProducts();
});

final newProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.read(productRepositoryProvider).watchNewProducts();
});

final hotProductsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.read(productRepositoryProvider).watchHotProducts();
});

// Provider thống kê sản phẩm
final productStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.read(productRepositoryProvider).getProductStats();
});

// Provider thương hiệu
final brandsProvider = FutureProvider<List<String>>((ref) async {
  try {
    return await ref.read(productRepositoryProvider).getBrands();
  } catch (e) {
    NotificationUtils.showError(
      'Lỗi tải danh sách thương hiệu: ${e.toString()}',
    );
    return [];
  }
});

// Provider danh mục
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    return await ref.read(productRepositoryProvider).getCategories();
  } catch (e) {
    NotificationUtils.showError('Lỗi tải danh sách danh mục: ${e.toString()}');
    return [];
  }
});
