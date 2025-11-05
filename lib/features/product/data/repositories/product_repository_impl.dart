import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    final dataList = await remoteDataSource.getFeaturedProducts();
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> getHotProducts() async {
    final dataList = await remoteDataSource.getHotProducts();
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> getNewProducts() async {
    final dataList = await remoteDataSource.getNewProducts();
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final data = await remoteDataSource.getProductById(id);
    if (data == null) return null;
    return ProductModel.fromMap(data).toEntity();
  }

  @override
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) async {
    final dataList = await remoteDataSource.getProducts(
      category: category,
      brand: brand,
      isActive: isActive,
      isFeatured: isFeatured,
      limit: limit,
    );
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    String category, {
    int? limit,
  }) async {
    final dataList = await remoteDataSource.getProductsByCategory(
      category,
      limit: limit,
    );
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    final dataList = await remoteDataSource.searchProducts(
      query,
      category: category,
      brand: brand,
      limit: limit,
    );
    return dataList
        .map((data) => ProductModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final id = await remoteDataSource.createProduct(model.toFirestore());
    final data = await remoteDataSource.getProductById(id);
    return ProductModel.fromMap(data!).toEntity();
  }

  @override
  Future<void> deleteProduct(String productId) {
    return remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<void> updateProduct(ProductEntity product) {
    final model = ProductModel.fromEntity(product);
    return remoteDataSource.updateProduct(product.id, model.toFirestore());
  }

  // Các thao tác stock đã chuyển sang feature Inventory (tuân thủ SRP)
  // Sử dụng InventoryRepository cho tất cả thao tác quản lý stock

  @override
  Stream<ProductEntity?> watchProduct(String productId) {
    return remoteDataSource
        .watchProduct(productId)
        .map(
          (data) => data != null ? ProductModel.fromMap(data).toEntity() : null,
        );
  }

  @override
  Stream<List<ProductEntity>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) {
    return remoteDataSource
        .watchProducts(
          category: category,
          brand: brand,
          isActive: isActive,
          isFeatured: isFeatured,
          limit: limit,
        )
        .map(
          (dataList) => dataList
              .map((data) => ProductModel.fromMap(data).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<ProductEntity>> watchFeaturedProducts() {
    return remoteDataSource.watchFeaturedProducts().map(
      (dataList) => dataList
          .map((data) => ProductModel.fromMap(data).toEntity())
          .toList(),
    );
  }

  @override
  Stream<List<ProductEntity>> watchNewProducts() {
    return remoteDataSource.watchNewProducts().map(
      (dataList) => dataList
          .map((data) => ProductModel.fromMap(data).toEntity())
          .toList(),
    );
  }

  @override
  Stream<List<ProductEntity>> watchHotProducts() {
    return remoteDataSource.watchHotProducts().map(
      (dataList) => dataList
          .map((data) => ProductModel.fromMap(data).toEntity())
          .toList(),
    );
  }

  @override
  Future<Map<String, dynamic>> getProductStats() {
    return remoteDataSource.getProductStats();
  }

  @override
  Future<List<String>> getBrands() {
    return remoteDataSource.getBrands();
  }

  @override
  Future<List<String>> getCategories() {
    return remoteDataSource.getCategories();
  }
}
