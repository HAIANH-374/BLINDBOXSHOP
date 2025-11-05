import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/reorder_categories_usecase.dart';
import '../../domain/usecases/update_category_status_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/watch_categories_usecase.dart';
import 'category_di.dart';

 
final categoriesProvider =
    FutureProvider.family<List<CategoryEntity>, GetCategoriesParams>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(getCategoriesUseCaseProvider);
      return await useCase(params);
    });

final activeCategoriesProvider =
    FutureProvider.family<List<CategoryEntity>, int?>((ref, limit) async {
      final useCase = ref.watch(getActiveCategoriesUseCaseProvider);
      return await useCase(limit: limit);
    });

final categoryByIdProvider = FutureProvider.family<CategoryEntity?, String>((
  ref,
  categoryId,
) async {
  final useCase = ref.watch(getCategoryByIdUseCaseProvider);
  return await useCase(categoryId);
});

final searchCategoriesProvider =
    FutureProvider.family<List<CategoryEntity>, String>((ref, query) async {
      final useCase = ref.watch(searchCategoriesUseCaseProvider);
      return await useCase(query);
    });

final categoryStatsProvider = FutureProvider<CategoryStatsEntity>((ref) async {
  final useCase = ref.watch(getCategoryStatsUseCaseProvider);
  return await useCase();
});

 
final watchCategoriesProvider =
    StreamProvider.family<List<CategoryEntity>, WatchCategoriesParams>((
      ref,
      params,
    ) {
      final useCase = ref.watch(watchCategoriesUseCaseProvider);
      return useCase(params);
    });

final watchActiveCategoriesProvider =
    StreamProvider.family<List<CategoryEntity>, int?>((ref, limit) {
      final params = WatchCategoriesParams(isActive: true, limit: limit);
      final useCase = ref.watch(watchCategoriesUseCaseProvider);
      return useCase(params);
    });

 
final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>(
      (ref) => CategoryNotifier(
        createCategoryUseCase: ref.watch(createCategoryUseCaseProvider),
        updateCategoryUseCase: ref.watch(updateCategoryUseCaseProvider),
        deleteCategoryUseCase: ref.watch(deleteCategoryUseCaseProvider),
        updateCategoryStatusUseCase: ref.watch(
          updateCategoryStatusUseCaseProvider,
        ),
        reorderCategoriesUseCase: ref.watch(reorderCategoriesUseCaseProvider),
      ),
    );

class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final UpdateCategoryStatusUseCase _updateCategoryStatusUseCase;
  final ReorderCategoriesUseCase _reorderCategoriesUseCase;

  CategoryNotifier({
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
    required UpdateCategoryStatusUseCase updateCategoryStatusUseCase,
    required ReorderCategoriesUseCase reorderCategoriesUseCase,
  }) : _createCategoryUseCase = createCategoryUseCase,
       _updateCategoryUseCase = updateCategoryUseCase,
       _deleteCategoryUseCase = deleteCategoryUseCase,
       _updateCategoryStatusUseCase = updateCategoryStatusUseCase,
       _reorderCategoriesUseCase = reorderCategoriesUseCase,
       super(const AsyncValue.data(null));

  Future<CategoryEntity?> createCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      final newCategory = await _createCategoryUseCase(category);
      state = const AsyncValue.data(null);
      return newCategory;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<bool> updateCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      await _updateCategoryUseCase(category);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteCategoryUseCase(categoryId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateCategoryStatus(String categoryId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      final params = UpdateCategoryStatusParams(
        categoryId: categoryId,
        isActive: isActive,
      );
      await _updateCategoryStatusUseCase(params);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> activateCategory(String categoryId) async {
    return await updateCategoryStatus(categoryId, true);
  }

  Future<bool> deactivateCategory(String categoryId) async {
    return await updateCategoryStatus(categoryId, false);
  }

  Future<bool> reorderCategories(List<String> categoryIds) async {
    state = const AsyncValue.loading();
    try {
      await _reorderCategoriesUseCase(categoryIds);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
