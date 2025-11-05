import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });

  Future<List<ProductEntity>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  });

  Future<List<ProductEntity>> getFeaturedProducts();
  Future<List<ProductEntity>> getNewProducts();
  Future<List<ProductEntity>> getHotProducts();

  Future<List<ProductEntity>> getProductsByCategory(
    String category, {
    int? limit,
  });

  Future<ProductEntity?> getProductById(String id);

  Future<ProductEntity> createProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);

  Stream<ProductEntity?> watchProduct(String productId);

  Stream<List<ProductEntity>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });

  Stream<List<ProductEntity>> watchFeaturedProducts();
  Stream<List<ProductEntity>> watchNewProducts();
  Stream<List<ProductEntity>> watchHotProducts();

  Future<Map<String, dynamic>> getProductStats();
  Future<List<String>> getBrands();
  Future<List<String>> getCategories();
}
