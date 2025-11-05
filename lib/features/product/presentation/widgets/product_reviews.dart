import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../review/domain/entities/review_entity.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'review_widget.dart';

class ProductReviews extends ConsumerStatefulWidget {
  final String productId;
  final double rating;
  final int reviewCount;

  const ProductReviews({
    super.key,
    required this.productId,
    required this.rating,
    required this.reviewCount,
  });

  @override
  ConsumerState<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends ConsumerState<ProductReviews> {
  String _sortBy = 'newest';
  int _limit = 10;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(
      reviewsByProductProvider((
        productId: widget.productId,
        status: ReviewStatus.approved,
        limit: _limit,
        sortBy: _sortBy,
      )),
    );
    final reviewStatsAsync = ref.watch(reviewStatsProvider(widget.productId));
    final authState = ref.watch(authProvider);
    final currentUserId = authState.firebaseUser?.uid;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Đánh giá sản phẩm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Mới nhất'),
                        ),
                        DropdownMenuItem(
                          value: 'highest_rating',
                          child: Text('Đánh giá cao'),
                        ),
                        DropdownMenuItem(
                          value: 'lowest_rating',
                          child: Text('Đánh giá thấp'),
                        ),
                        DropdownMenuItem(
                          value: 'most_helpful',
                          child: Text('Hữu ích'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _sortBy = v);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      _showAllReviewsDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          reviewStatsAsync.when(
            data: (stats) => _buildRatingSummary(context, stats),
            loading: () => _buildLoadingStats(),
            error: (error, stack) => _buildLoadingStats(),
          ),

          SizedBox(height: 20.h),

          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.rate_review,
                      size: 48.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Chưa có đánh giá nào',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }

              return Column(
                children: [
                  ...reviews
                      .take(3)
                      .map(
                        (review) => ReviewWidget(
                          review: review,
                          currentUserId: currentUserId,
                          onMarkHelpful: currentUserId == null
                              ? null
                              : () async {
                                  await ref
                                      .read(reviewNotifierProvider.notifier)
                                      .markHelpful(review.id, currentUserId);
                                  ref.invalidate(reviewsByProductProvider);
                                },
                          onUnmarkHelpful: currentUserId == null
                              ? null
                              : () async {
                                  // Lưu ý: markHelpful có thể được sử dụng để toggle
                                  await ref
                                      .read(reviewNotifierProvider.notifier)
                                      .markHelpful(review.id, currentUserId);
                                  ref.invalidate(reviewsByProductProvider);
                                },
                        ),
                      ),
                  SizedBox(height: 16.h),
                  if (reviews.length >= _limit)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _limit += 10);
                        },
                        child: const Text('Tải thêm'),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi tải đánh giá: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showWriteReviewDialog(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: AppColors.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: ReviewFormWidget(
                      productId: widget.productId,
                      userId: ref.read(authProvider).firebaseUser?.uid ?? '',
                      userName:
                          ref.read(profileProvider).profile?.name ??
                          'Người dùng',
                      userAvatar:
                          ref.read(profileProvider).profile?.avatar ?? '',
                      onSubmitted: () {
                        Navigator.pop(context);
                        ref.invalidate(reviewsByProductProvider);
                        ref.invalidate(reviewStatsProvider);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, ReviewStatsEntity stats) {
    return Row(
      children: [
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < stats.averageRating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.warning,
                  size: 16.sp,
                );
              }),
            ),
            SizedBox(height: 4.h),
            Text(
              '${stats.totalReviews} đánh giá',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Text(
          widget.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.warning,
                  size: 16.sp,
                );
              }),
            ),
            SizedBox(height: 4.h),
            Text(
              '${widget.reviewCount} đánh giá',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  void _showAllReviewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _AllReviewsDialog(productId: widget.productId, sortBy: _sortBy),
    );
  }
}

class _AllReviewsDialog extends ConsumerStatefulWidget {
  final String productId;
  final String sortBy;

  const _AllReviewsDialog({required this.productId, required this.sortBy});

  @override
  ConsumerState<_AllReviewsDialog> createState() => _AllReviewsDialogState();
}

class _AllReviewsDialogState extends ConsumerState<_AllReviewsDialog> {
  int _dialogLimit = 20;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(
      reviewsByProductProvider((
        productId: widget.productId,
        status: ReviewStatus.approved,
        limit: _dialogLimit,
        sortBy: widget.sortBy,
      )),
    );
    final authState = ref.watch(authProvider);
    final currentUserId = authState.firebaseUser?.uid;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tất cả đánh giá',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const Center(child: Text('Chưa có đánh giá nào'));
                  }
                  return ListView.builder(
                    itemCount: reviews.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= reviews.length) {
                        // Nút tải thêm
                        if (reviews.length >= _dialogLimit) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() => _dialogLimit += 10);
                                },
                                child: const Text('Tải thêm'),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      final review = reviews[index];
                      return ReviewWidget(
                        review: review,
                        currentUserId: currentUserId,
                        onMarkHelpful: currentUserId == null
                            ? null
                            : () async {
                                await ref
                                    .read(reviewNotifierProvider.notifier)
                                    .markHelpful(review.id, currentUserId);
                                ref.invalidate(reviewsByProductProvider);
                              },
                        onUnmarkHelpful: currentUserId == null
                            ? null
                            : () async {
                                await ref
                                    .read(reviewNotifierProvider.notifier)
                                    .markHelpful(review.id, currentUserId);
                                ref.invalidate(reviewsByProductProvider);
                              },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Lỗi: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
