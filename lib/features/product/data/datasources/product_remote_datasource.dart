import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProductRemoteDataSource {
  // Truy vấn
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });

  Future<List<Map<String, dynamic>>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  });

  Future<List<Map<String, dynamic>>> getFeaturedProducts();
  Future<List<Map<String, dynamic>>> getNewProducts();
  Future<List<Map<String, dynamic>>> getHotProducts();
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category, {
    int? limit,
  });
  Future<Map<String, dynamic>?> getProductById(String id);

  // Thao tác thay đổi
  Future<String> createProduct(Map<String, dynamic> productData);
  Future<void> updateProduct(String id, Map<String, dynamic> productData);
  Future<void> deleteProduct(String productId);
  Future<int?> getStock(
    String productId,
  ); // Chỉ đọc, giữ lại để hiển thị sản phẩm

  // Streams
  Stream<Map<String, dynamic>?> watchProduct(String productId);
  Stream<List<Map<String, dynamic>>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  });
  Stream<List<Map<String, dynamic>>> watchFeaturedProducts();
  Stream<List<Map<String, dynamic>>> watchNewProducts();
  Stream<List<Map<String, dynamic>>> watchHotProducts();

  // Thống kê
  Future<Map<String, dynamic>> getProductStats();
  Future<List<String>> getBrands();
  Future<List<String>> getCategories();
}

/// Implementation của Remote Data Source
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'products';

  ProductRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (brand != null) {
        query = query.where('brand', isEqualTo: brand);
      }
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy danh sách sản phẩm: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(
    String query, {
    String? category,
    String? brand,
    int? limit,
  }) async {
    try {
      Query firestoreQuery = _firestore.collection(_collection);

      // Tìm kiếm theo từ khóa
      firestoreQuery = firestoreQuery.where(
        'searchKeywords',
        arrayContains: query.toLowerCase(),
      );

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
      }
      if (brand != null) {
        firestoreQuery = firestoreQuery.where('brand', isEqualTo: brand);
      }
      if (limit != null) {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final snapshot = await firestoreQuery.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi tìm kiếm sản phẩm: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('sold', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy sản phẩm nổi bật: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNewProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy sản phẩm mới: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHotProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sold', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy sản phẩm hot: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category, {
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy sản phẩm theo danh mục: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return {...doc.data()!, 'id': doc.id};
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy thông tin sản phẩm: ${e.message}');
    }
  }

  @override
  Future<String> createProduct(Map<String, dynamic> productData) async {
    try {
      final data = {
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi tạo sản phẩm: ${e.message}');
    }
  }

  @override
  Future<void> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final data = {...productData, 'updatedAt': FieldValue.serverTimestamp()};
      await _firestore.collection(_collection).doc(id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi cập nhật sản phẩm: ${e.message}');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi xóa sản phẩm: ${e.message}');
    }
  }

  // Các thao tác stock đã chuyển sang feature Inventory (tuân thủ SRP)
  // Các phương thức này được giữ lại trong datasource để tương thích ngược nhưng đã lỗi thời
  // Sử dụng InventoryRemoteDataSource cho tất cả thao tác stock

  @override
  Future<int?> getStock(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (!doc.exists) return null;
      return doc.data()?['stock'] as int?;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy thông tin tồn kho: ${e.message}');
    }
  }

  // Streams
  @override
  Stream<Map<String, dynamic>?> watchProduct(String productId) {
    return _firestore
        .collection(_collection)
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists ? {...doc.data()!, 'id': doc.id} : null);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchProducts({
    String? category,
    String? brand,
    bool? isActive,
    bool? isFeatured,
    int? limit,
  }) {
    Query query = _firestore.collection(_collection);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (brand != null) {
      query = query.where('brand', isEqualTo: brand);
    }
    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    if (isFeatured != null) {
      query = query.where('isFeatured', isEqualTo: isFeatured);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList(),
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> watchFeaturedProducts() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('sold', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  @override
  Stream<List<Map<String, dynamic>>> watchNewProducts() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  @override
  Stream<List<Map<String, dynamic>>> watchHotProducts() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('sold', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Stats
  @override
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final products = snapshot.docs.map((doc) => doc.data()).toList();

      int totalProducts = products.length;
      int activeProducts = products.where((p) => p['isActive'] == true).length;
      int outOfStock = products.where((p) => (p['stock'] ?? 0) == 0).length;
      double totalValue = products.fold(
        0.0,
        (sum, p) => sum + ((p['price'] ?? 0.0) * (p['stock'] ?? 0)),
      );

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'outOfStock': outOfStock,
        'totalValue': totalValue,
      };
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy thống kê sản phẩm: ${e.message}');
    }
  }

  @override
  Future<List<String>> getBrands() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final brands = snapshot.docs
          .map((doc) => doc.data()['brand'] as String?)
          .where((brand) => brand != null && brand.isNotEmpty)
          .toSet()
          .toList();
      return brands.cast<String>();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy danh sách thương hiệu: ${e.message}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .toSet()
          .toList();
      return categories.cast<String>();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: ${e.message}');
    }
  }
}
