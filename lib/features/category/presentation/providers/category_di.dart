import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_active_categories_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_by_id_usecase.dart';
import '../../domain/usecases/get_category_stats_usecase.dart';
import '../../domain/usecases/reorder_categories_usecase.dart';
import '../../domain/usecases/search_categories_usecase.dart';
import '../../domain/usecases/update_category_status_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/watch_categories_usecase.dart';

/// Provider cho FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider cho CategoryRemoteDataSource
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return CategoryRemoteDataSourceImpl(firestore);
});

/// Provider cho CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource);
});

// ============================================================
// UseCase Providers
// ============================================================

/// Provider cho GetCategoriesUseCase
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

/// Provider cho GetActiveCategoriesUseCase
final getActiveCategoriesUseCaseProvider = Provider<GetActiveCategoriesUseCase>(
  (ref) {
    final repository = ref.watch(categoryRepositoryProvider);
    return GetActiveCategoriesUseCase(repository);
  },
);

/// Provider cho GetCategoryByIdUseCase
final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoryByIdUseCase(repository);
});

/// Provider cho SearchCategoriesUseCase
final searchCategoriesUseCaseProvider = Provider<SearchCategoriesUseCase>((
  ref,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return SearchCategoriesUseCase(repository);
});

/// Provider cho CreateCategoryUseCase
final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CreateCategoryUseCase(repository);
});

/// Provider cho UpdateCategoryUseCase
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategoryUseCase(repository);
});

/// Provider cho DeleteCategoryUseCase
final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategoryUseCase(repository);
});

/// Provider cho UpdateCategoryStatusUseCase
final updateCategoryStatusUseCaseProvider =
    Provider<UpdateCategoryStatusUseCase>((ref) {
      final repository = ref.watch(categoryRepositoryProvider);
      return UpdateCategoryStatusUseCase(repository);
    });

/// Provider cho ReorderCategoriesUseCase
final reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((
  ref,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return ReorderCategoriesUseCase(repository);
});

/// Provider cho GetCategoryStatsUseCase
final getCategoryStatsUseCaseProvider = Provider<GetCategoryStatsUseCase>((
  ref,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoryStatsUseCase(repository);
});

/// Provider cho WatchCategoriesUseCase
final watchCategoriesUseCaseProvider = Provider<WatchCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return WatchCategoriesUseCase(repository);
});
