import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_reviews_by_product_usecase.dart';
import '../../domain/usecases/get_review_stats_usecase.dart';
import '../../domain/usecases/get_pending_reviews_usecase.dart';
import '../../domain/usecases/get_user_reviews_usecase.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/update_review_usecase.dart';
import '../../domain/usecases/approve_review_usecase.dart';
import '../../domain/usecases/reject_review_usecase.dart';
import '../../domain/usecases/mark_helpful_usecase.dart';
import '../../domain/usecases/has_user_reviewed_usecase.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    remoteDataSource: ref.watch(reviewRemoteDataSourceProvider),
  );
});

final getReviewsByProductUseCaseProvider = Provider<GetReviewsByProductUseCase>(
  (ref) {
    return GetReviewsByProductUseCase(ref.watch(reviewRepositoryProvider));
  },
);

final getReviewStatsUseCaseProvider = Provider<GetReviewStatsUseCase>((ref) {
  return GetReviewStatsUseCase(ref.watch(reviewRepositoryProvider));
});

final getPendingReviewsUseCaseProvider = Provider<GetPendingReviewsUseCase>((
  ref,
) {
  return GetPendingReviewsUseCase(ref.watch(reviewRepositoryProvider));
});

final getUserReviewsUseCaseProvider = Provider<GetUserReviewsUseCase>((ref) {
  return GetUserReviewsUseCase(ref.watch(reviewRepositoryProvider));
});

final createReviewUseCaseProvider = Provider<CreateReviewUseCase>((ref) {
  return CreateReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final updateReviewUseCaseProvider = Provider<UpdateReviewUseCase>((ref) {
  return UpdateReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final deleteReviewUseCaseProvider = Provider<DeleteReviewUseCase>((ref) {
  return DeleteReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final approveReviewUseCaseProvider = Provider<ApproveReviewUseCase>((ref) {
  return ApproveReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final rejectReviewUseCaseProvider = Provider<RejectReviewUseCase>((ref) {
  return RejectReviewUseCase(ref.watch(reviewRepositoryProvider));
});

final markHelpfulUseCaseProvider = Provider<MarkHelpfulUseCase>((ref) {
  return MarkHelpfulUseCase(ref.watch(reviewRepositoryProvider));
});

final hasUserReviewedUseCaseProvider = Provider<HasUserReviewedUseCase>((ref) {
  return HasUserReviewedUseCase(ref.watch(reviewRepositoryProvider));
});
