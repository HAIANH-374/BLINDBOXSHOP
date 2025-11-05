import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface định nghĩa các phương thức truy cập dữ liệu Category từ Firestore
abstract class CategoryRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });

  Future<Map<String, dynamic>?> getCategoryById(String categoryId);

  Future<List<Map<String, dynamic>>> getActiveCategories({int? limit});

  Future<Map<String, dynamic>?> getCategoryByName(String name);

  Future<List<Map<String, dynamic>>> searchCategories(String query);

  Future<Map<String, dynamic>?> getNextCategory(int currentOrder);

  Future<Map<String, dynamic>?> getPreviousCategory(int currentOrder);

  Future<List<String>> getCategoryNames();

  Future<Map<String, dynamic>> getCategoryStats();

  Future<bool> categoryExists(String name);

  Future<String> createCategory(Map<String, dynamic> categoryData);

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> categoryData,
  );

  Future<void> updateCategoryStatus(String categoryId, bool isActive);

  Future<void> updateCategoryOrder(String categoryId, int newOrder);

  Future<void> reorderCategories(List<String> categoryIds);

  Future<void> deleteCategory(String categoryId);

  Stream<Map<String, dynamic>?> watchCategory(String categoryId);

  Stream<List<Map<String, dynamic>>> watchCategories({
    bool? isActive,
    int? limit,
  });
}

/// Implementation của CategoryRemoteDataSource sử dụng Firestore
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _categoriesCollection = 'categories';

  CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Map<String, dynamic>>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(_categoriesCollection);

      // Apply filters
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('order', descending: false);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveCategories({int? limit}) async {
    try {
      return await getCategories(
        isActive: true,
        limit: limit,
        orderBy: 'order',
        descending: false,
      );
    } catch (e) {
      throw Exception('Lỗi lấy danh mục đang hoạt động: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCategoryByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection(_categoriesCollection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Lỗi lấy danh mục theo tên: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchCategories(String query) async {
    try {
      final snapshot = await _firestore.collection(_categoriesCollection).get();

      List<Map<String, dynamic>> categories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter by query
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        categories = categories.where((category) {
          final name = (category['name'] as String? ?? '').toLowerCase();
          final description = (category['description'] as String? ?? '')
              .toLowerCase();
          return name.contains(lowerQuery) || description.contains(lowerQuery);
        }).toList();
      }

      // Sort by order
      categories.sort((a, b) {
        final orderA = a['order'] as int? ?? 0;
        final orderB = b['order'] as int? ?? 0;
        return orderA.compareTo(orderB);
      });

      return categories;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm danh mục: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getNextCategory(int currentOrder) async {
    try {
      final snapshot = await _firestore
          .collection(_categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('order', isGreaterThan: currentOrder)
          .orderBy('order')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Lỗi lấy danh mục tiếp theo: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPreviousCategory(int currentOrder) async {
    try {
      final snapshot = await _firestore
          .collection(_categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('order', isLessThan: currentOrder)
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Lỗi lấy danh mục trước đó: $e');
    }
  }

  @override
  Future<List<String>> getCategoryNames() async {
    try {
      final categories = await getActiveCategories();
      return categories
          .map((data) => data['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách tên danh mục: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryStats() async {
    try {
      final snapshot = await _firestore.collection(_categoriesCollection).get();

      final categories = snapshot.docs.map((doc) => doc.data()).toList();

      final totalCategories = categories.length;
      final activeCategories = categories
          .where((c) => c['isActive'] == true)
          .length;
      final inactiveCategories = categories
          .where((c) => c['isActive'] != true)
          .length;

      return {
        'totalCategories': totalCategories,
        'activeCategories': activeCategories,
        'inactiveCategories': inactiveCategories,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê danh mục: $e');
    }
  }

  @override
  Future<bool> categoryExists(String name) async {
    try {
      final category = await getCategoryByName(name);
      return category != null;
    } catch (e) {
      throw Exception('Lỗi kiểm tra danh mục: $e');
    }
  }

  @override
  Future<String> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final docRef = await _firestore
          .collection(_categoriesCollection)
          .add(categoryData);

      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo danh mục: $e');
    }
  }

  @override
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> categoryData,
  ) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .update(categoryData);
    } catch (e) {
      throw Exception('Lỗi cập nhật danh mục: $e');
    }
  }

  @override
  Future<void> updateCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(categoryId).update(
        {'isActive': isActive, 'updatedAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái danh mục: $e');
    }
  }

  @override
  Future<void> updateCategoryOrder(String categoryId, int newOrder) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(categoryId).update(
        {'order': newOrder, 'updatedAt': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật thứ tự danh mục: $e');
    }
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < categoryIds.length; i++) {
        final categoryRef = _firestore
            .collection(_categoriesCollection)
            .doc(categoryIds[i]);
        batch.update(categoryRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi sắp xếp lại danh mục: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi xóa danh mục: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchCategory(String categoryId) {
    return _firestore
        .collection(_categoriesCollection)
        .doc(categoryId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          final data = snapshot.data() as Map<String, dynamic>;
          data['id'] = snapshot.id;
          return data;
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCategories({
    bool? isActive,
    int? limit,
  }) {
    Query query = _firestore.collection(_categoriesCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('order', descending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
