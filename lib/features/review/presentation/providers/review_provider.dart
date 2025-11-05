import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/notification_utils.dart';
import '../../domain/entities/review_entity.dart';
import 'review_di.dart';

final reviewsByProductProvider =
    FutureProvider.family<
      List<ReviewEntity>,
      ({String productId, ReviewStatus? status, int? limit, String? sortBy})
    >((ref, params) async {
      try {
        final useCase = ref.watch(getReviewsByProductUseCaseProvider);
        return await useCase(
          params.productId,
          status: params.status,
          limit: params.limit,
          sortBy: params.sortBy,
        );
      } catch (e) {
        NotificationUtils.showError('Lỗi tải đánh giá: ${e.toString()}');
        return [];
      }
    });

final reviewStatsProvider = FutureProvider.family<ReviewStatsEntity, String>((
  ref,
  productId,
) async {
  try {
    final useCase = ref.watch(getReviewStatsUseCaseProvider);
    return await useCase(productId);
  } catch (e) {
    NotificationUtils.showError('Lỗi tải thống kê: ${e.toString()}');
    return const ReviewStatsEntity(
      totalReviews: 0,
      averageRating: 0.0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      verifiedReviews: 0,
      withImages: 0,
    );
  }
});

final pendingReviewsProvider = FutureProvider<List<ReviewEntity>>((ref) async {
  try {
    final useCase = ref.watch(getPendingReviewsUseCaseProvider);
    return await useCase();
  } catch (e) {
    NotificationUtils.showError('Lỗi tải đánh giá chờ duyệt: ${e.toString()}');
    return [];
  }
});

final userReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((
  ref,
  userId,
) async {
  try {
    final useCase = ref.watch(getUserReviewsUseCaseProvider);
    return await useCase(userId);
  } catch (e) {
    NotificationUtils.showError('Lỗi tải đánh giá của bạn: ${e.toString()}');
    return [];
  }
});

final hasUserReviewedProvider =
    FutureProvider.family<bool, ({String productId, String userId})>((
      ref,
      params,
    ) async {
      try {
        final useCase = ref.watch(hasUserReviewedUseCaseProvider);
        return await useCase(params.productId, params.userId);
      } catch (e) {
        return false;
      }
    });

class ReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ReviewNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<bool> createReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(createReviewUseCaseProvider);
      await useCase(review);
      state = const AsyncValue.data(null);
      NotificationUtils.showSuccess('Đánh giá của bạn đã được gửi!');
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      NotificationUtils.showError('Lỗi tạo đánh giá: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateReview(ReviewEntity review) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(updateReviewUseCaseProvider);
      await useCase(review);
      state = const AsyncValue.data(null);
      NotificationUtils.showSuccess('Đánh giá đã được cập nhật!');
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      NotificationUtils.showError('Lỗi cập nhật đánh giá: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(deleteReviewUseCaseProvider);
      await useCase(reviewId);
      state = const AsyncValue.data(null);
      NotificationUtils.showSuccess('Đánh giá đã được xóa!');
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      NotificationUtils.showError('Lỗi xóa đánh giá: ${e.toString()}');
      return false;
    }
  }

  Future<bool> approveReview(String reviewId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(approveReviewUseCaseProvider);
      await useCase(reviewId);
      state = const AsyncValue.data(null);
      NotificationUtils.showSuccess('Đã duyệt đánh giá!');
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      NotificationUtils.showError('Lỗi duyệt đánh giá: ${e.toString()}');
      return false;
    }
  }

  Future<bool> rejectReview(String reviewId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(rejectReviewUseCaseProvider);
      await useCase(reviewId);
      state = const AsyncValue.data(null);
      NotificationUtils.showSuccess('Đã từ chối đánh giá!');
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      NotificationUtils.showError('Lỗi từ chối đánh giá: ${e.toString()}');
      return false;
    }
  }

  Future<bool> markHelpful(String reviewId, String userId) async {
    try {
      final useCase = ref.read(markHelpfulUseCaseProvider);
      await useCase(reviewId, userId);
      NotificationUtils.showSuccess('Cảm ơn đánh giá của bạn!');
      return true;
    } catch (e) {
      NotificationUtils.showError(e.toString());
      return false;
    }
  }
}

final reviewNotifierProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<void>>((ref) {
      return ReviewNotifier(ref);
    });
