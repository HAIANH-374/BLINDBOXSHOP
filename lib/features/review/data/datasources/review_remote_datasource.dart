import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ReviewRemoteDataSource {
  Future<List<Map<String, dynamic>>> getReviews({
    String? productId,
    String? userId,
    String? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  });

  Future<Map<String, dynamic>?> getReviewById(String reviewId);

  Future<List<Map<String, dynamic>>> getReviewsByProduct(
    String productId, {
    String? status,
    int? limit,
    String? sortBy,
  });

  Future<List<Map<String, dynamic>>> getUserReviews(String userId);

  Future<List<Map<String, dynamic>>> getPendingReviews();

  Future<Map<String, dynamic>> getReviewStats(String productId);

  Future<String> createReview(Map<String, dynamic> data);

  Future<void> updateReview(String reviewId, Map<String, dynamic> data);

  Future<void> deleteReview(String reviewId);

  Future<void> approveReview(String reviewId);

  Future<void> rejectReview(String reviewId);

  Future<void> markHelpful(String reviewId, String userId);

  Future<void> unmarkHelpful(String reviewId, String userId);

  Future<List<Map<String, dynamic>>> searchReviews(String query);

  Stream<Map<String, dynamic>?> watchReview(String reviewId);

  Stream<List<Map<String, dynamic>>> watchReviewsByProduct(
    String productId, {
    String? status,
    int? limit,
  });

  Stream<List<Map<String, dynamic>>> watchUserReviews(String userId);

  Stream<List<Map<String, dynamic>>> watchPendingReviews();
}

/// Implementation Review Remote DataSource
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _reviewsCollection = 'reviews';

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<Map<String, dynamic>>> getReviews({
    String? productId,
    String? userId,
    String? status,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = firestore.collection(_reviewsCollection);

      // Áp dụng bộ lọc
      if (productId != null && productId.isNotEmpty) {
        query = query.where('productId', isEqualTo: productId);
      }
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      // Áp dụng sắp xếp
      if (orderBy != null) {
        String actualField;
        switch (orderBy) {
          case 'newest':
            actualField = 'createdAt';
            break;
          case 'oldest':
            actualField = 'createdAt';
            descending = false;
            break;
          case 'highest_rating':
            actualField = 'rating';
            break;
          case 'lowest_rating':
            actualField = 'rating';
            descending = false;
            break;
          case 'most_helpful':
            actualField = 'helpfulCount';
            break;
          default:
            actualField = orderBy;
        }
        query = query.orderBy(actualField, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: descending);
      }

      // Áp dụng giới hạn
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đánh giá: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getReviewById(String reviewId) async {
    try {
      final doc = await firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();
      if (!doc.exists) return null;
      return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReviewsByProduct(
    String productId, {
    String? status,
    int? limit,
    String? sortBy,
  }) async {
    return await getReviews(
      productId: productId,
      status: status ?? 'approved',
      limit: limit,
      orderBy: sortBy,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    return await getReviews(
      userId: userId,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingReviews() async {
    return await getReviews(
      status: 'pending',
      orderBy: 'createdAt',
      descending: true,
    );
  }

  @override
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      final reviews = await getReviewsByProduct(productId, status: 'approved');

      if (reviews.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          'verifiedReviews': 0,
          'withImages': 0,
        };
      }

      final totalReviews = reviews.length;
      final averageRating =
          reviews.fold(0.0, (sum, review) => sum + (review['rating'] ?? 0)) /
          totalReviews;

      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final review in reviews) {
        final rating = review['rating'] ?? 5;
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      final verifiedReviews = reviews
          .where((r) => r['isVerified'] == true)
          .length;
      final withImages = reviews
          .where((r) => (r['images'] as List? ?? []).isNotEmpty)
          .length;

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'verifiedReviews': verifiedReviews,
        'withImages': withImages,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê đánh giá: $e');
    }
  }

  @override
  Future<String> createReview(Map<String, dynamic> data) async {
    try {
      final docRef = await firestore.collection(_reviewsCollection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo đánh giá: $e');
    }
  }

  @override
  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).update(data);
    } catch (e) {
      throw Exception('Lỗi cập nhật đánh giá: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa đánh giá: $e');
    }
  }

  @override
  Future<void> approveReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi duyệt đánh giá: $e');
    }
  }

  @override
  Future<void> rejectReview(String reviewId) async {
    try {
      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi từ chối đánh giá: $e');
    }
  }

  @override
  Future<void> markHelpful(String reviewId, String userId) async {
    try {
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw Exception('Đánh giá không tồn tại');
      }

      final helpfulUsers = List<String>.from(review['helpfulUsers'] ?? []);
      if (helpfulUsers.contains(userId)) {
        throw Exception('Bạn đã đánh dấu hữu ích rồi');
      }

      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
        'helpfulUsers': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi đánh dấu hữu ích: $e');
    }
  }

  @override
  Future<void> unmarkHelpful(String reviewId, String userId) async {
    try {
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw Exception('Đánh giá không tồn tại');
      }

      final helpfulUsers = List<String>.from(review['helpfulUsers'] ?? []);
      if (!helpfulUsers.contains(userId)) {
        throw Exception('Bạn chưa đánh dấu hữu ích');
      }

      await firestore.collection(_reviewsCollection).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(-1),
        'helpfulUsers': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi bỏ đánh dấu hữu ích: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchReviews(String query) async {
    try {
      final snapshot = await firestore.collection(_reviewsCollection).get();
      List<Map<String, dynamic>> reviews = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      if (query.isNotEmpty) {
        reviews = reviews.where((review) {
          final comment = (review['comment'] ?? '').toString().toLowerCase();
          final userName = (review['userName'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return comment.contains(searchQuery) ||
              userName.contains(searchQuery);
        }).toList();
      }

      reviews.sort((a, b) {
        final aDate =
            (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bDate =
            (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      return reviews;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm đánh giá: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchReview(String reviewId) {
    return firestore
        .collection(_reviewsCollection)
        .doc(reviewId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return {
            ...snapshot.data() as Map<String, dynamic>,
            'id': snapshot.id,
          };
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchReviewsByProduct(
    String productId, {
    String? status,
    int? limit,
  }) {
    try {
      Query query = firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList();
      });
    } catch (e) {
      // Phương án dự phòng
      Query query = firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        List<Map<String, dynamic>> reviews = snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList();

        if (status != null) {
          reviews = reviews
              .where((review) => review['status'] == status)
              .toList();
        }

        return reviews;
      });
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserReviews(String userId) {
    return firestore
        .collection(_reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchPendingReviews() {
    return firestore
        .collection(_reviewsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }
}
