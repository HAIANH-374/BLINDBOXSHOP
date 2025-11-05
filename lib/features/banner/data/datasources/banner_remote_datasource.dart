import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BannerRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<Map<String, dynamic>?> getBannerById(String bannerId);
  Future<List<Map<String, dynamic>>> getActiveBanners({int? limit});
  Future<List<Map<String, dynamic>>> searchBanners(String query);
  Future<List<Map<String, dynamic>>> getBannersByLinkType(String linkType);
  Future<List<Map<String, dynamic>>> getBannersByLinkValue(String linkValue);
  Future<Map<String, dynamic>?> getNextBanner(int currentOrder);
  Future<Map<String, dynamic>?> getPreviousBanner(int currentOrder);
  Future<Map<String, dynamic>> getBannerStats();
  Future<String> createBanner(Map<String, dynamic> bannerData);
  Future<void> updateBanner(String bannerId, Map<String, dynamic> bannerData);
  Future<void> updateBannerStatus(String bannerId, bool isActive);
  Future<void> updateBannerOrder(String bannerId, int newOrder);
  Future<void> reorderBanners(List<String> bannerIds);
  Future<void> deleteBanner(String bannerId);
  Stream<Map<String, dynamic>?> watchBanner(String bannerId);
  Stream<List<Map<String, dynamic>>> watchBanners({bool? isActive, int? limit});
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _bannersCollection = 'banners';

  BannerRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Map<String, dynamic>>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(_bannersCollection);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('order', descending: false);
      }

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
      throw Exception('Lỗi lấy danh sách banner: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getBannerById(String bannerId) async {
    try {
      final doc = await _firestore
          .collection(_bannersCollection)
          .doc(bannerId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Lỗi lấy banner: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveBanners({int? limit}) async {
    return await getBanners(isActive: true, limit: limit);
  }

  @override
  Future<List<Map<String, dynamic>>> searchBanners(String query) async {
    try {
      final snapshot = await _firestore.collection(_bannersCollection).get();

      List<Map<String, dynamic>> banners = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        banners = banners.where((banner) {
          final title = (banner['title'] as String? ?? '').toLowerCase();
          final subtitle = (banner['subtitle'] as String? ?? '').toLowerCase();
          return title.contains(lowerQuery) || subtitle.contains(lowerQuery);
        }).toList();
      }

      banners.sort((a, b) {
        final orderA = a['order'] as int? ?? 0;
        final orderB = b['order'] as int? ?? 0;
        return orderA.compareTo(orderB);
      });

      return banners;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm banner: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBannersByLinkType(
    String linkType,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_bannersCollection)
          .where('linkType', isEqualTo: linkType)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi lấy banner theo loại link: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBannersByLinkValue(
    String linkValue,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_bannersCollection)
          .where('linkValue', isEqualTo: linkValue)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi lấy banner theo giá trị link: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getNextBanner(int currentOrder) async {
    try {
      final snapshot = await _firestore
          .collection(_bannersCollection)
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
      throw Exception('Lỗi lấy banner tiếp theo: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPreviousBanner(int currentOrder) async {
    try {
      final snapshot = await _firestore
          .collection(_bannersCollection)
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
      throw Exception('Lỗi lấy banner trước đó: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBannerStats() async {
    try {
      final snapshot = await _firestore.collection(_bannersCollection).get();

      final banners = snapshot.docs.map((doc) => doc.data()).toList();

      final totalBanners = banners.length;
      final activeBanners = banners.where((b) => b['isActive'] == true).length;
      final inactiveBanners = banners
          .where((b) => b['isActive'] != true)
          .length;

      return {
        'totalBanners': totalBanners,
        'activeBanners': activeBanners,
        'inactiveBanners': inactiveBanners,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê banner: $e');
    }
  }

  @override
  Future<String> createBanner(Map<String, dynamic> bannerData) async {
    try {
      final docRef = await _firestore
          .collection(_bannersCollection)
          .add(bannerData);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo banner: $e');
    }
  }

  @override
  Future<void> updateBanner(
    String bannerId,
    Map<String, dynamic> bannerData,
  ) async {
    try {
      await _firestore
          .collection(_bannersCollection)
          .doc(bannerId)
          .update(bannerData);
    } catch (e) {
      throw Exception('Lỗi cập nhật banner: $e');
    }
  }

  @override
  Future<void> updateBannerStatus(String bannerId, bool isActive) async {
    try {
      await _firestore.collection(_bannersCollection).doc(bannerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái banner: $e');
    }
  }

  @override
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    try {
      await _firestore.collection(_bannersCollection).doc(bannerId).update({
        'order': newOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật thứ tự banner: $e');
    }
  }

  @override
  Future<void> reorderBanners(List<String> bannerIds) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < bannerIds.length; i++) {
        final bannerRef = _firestore
            .collection(_bannersCollection)
            .doc(bannerIds[i]);
        batch.update(bannerRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi sắp xếp lại banner: $e');
    }
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection(_bannersCollection).doc(bannerId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa banner: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchBanner(String bannerId) {
    return _firestore
        .collection(_bannersCollection)
        .doc(bannerId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          final data = snapshot.data() as Map<String, dynamic>;
          data['id'] = snapshot.id;
          return data;
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchBanners({
    bool? isActive,
    int? limit,
  }) {
    Query query = _firestore.collection(_bannersCollection);

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
