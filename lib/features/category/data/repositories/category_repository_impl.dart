import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    final categoriesData = await _remoteDataSource.getCategories(
      isActive: isActive,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );

    return categoriesData
        .map((data) => CategoryModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    final categoryData = await _remoteDataSource.getCategoryById(categoryId);

    if (categoryData == null) return null;

    return CategoryModel.fromMap(categoryData).toEntity();
  }

  @override
  Future<List<CategoryEntity>> getActiveCategories({int? limit}) async {
    final categoriesData = await _remoteDataSource.getActiveCategories(
      limit: limit,
    );

    return categoriesData
        .map((data) => CategoryModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final categoryData = await _remoteDataSource.getCategoryByName(name);

    if (categoryData == null) return null;

    return CategoryModel.fromMap(categoryData).toEntity();
  }

  @override
  Future<List<CategoryEntity>> searchCategories(String query) async {
    final categoriesData = await _remoteDataSource.searchCategories(query);

    return categoriesData
        .map((data) => CategoryModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<CategoryEntity?> getNextCategory(int currentOrder) async {
    final categoryData = await _remoteDataSource.getNextCategory(currentOrder);

    if (categoryData == null) return null;

    return CategoryModel.fromMap(categoryData).toEntity();
  }

  @override
  Future<CategoryEntity?> getPreviousCategory(int currentOrder) async {
    final categoryData = await _remoteDataSource.getPreviousCategory(
      currentOrder,
    );

    if (categoryData == null) return null;

    return CategoryModel.fromMap(categoryData).toEntity();
  }

  @override
  Future<List<String>> getCategoryNames() async {
    return await _remoteDataSource.getCategoryNames();
  }

  @override
  Future<CategoryStatsEntity> getCategoryStats() async {
    final statsData = await _remoteDataSource.getCategoryStats();
    return CategoryStatsModel.fromMap(statsData).toEntity();
  }

  @override
  Future<bool> categoryExists(String name) async {
    return await _remoteDataSource.categoryExists(name);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    final newId = await _remoteDataSource.createCategory(
      categoryModel.toFirestore(),
    );

    return categoryModel.copyWith(id: newId).toEntity();
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await _remoteDataSource.updateCategory(
      category.id,
      categoryModel.toFirestore(),
    );
  }

  @override
  Future<void> updateCategoryStatus(String categoryId, bool isActive) async {
    await _remoteDataSource.updateCategoryStatus(categoryId, isActive);
  }

  @override
  Future<void> updateCategoryOrder(String categoryId, int newOrder) async {
    await _remoteDataSource.updateCategoryOrder(categoryId, newOrder);
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    await _remoteDataSource.reorderCategories(categoryIds);
  }

  @override
  Future<void> activateCategory(String categoryId) async {
    await updateCategoryStatus(categoryId, true);
  }

  @override
  Future<void> deactivateCategory(String categoryId) async {
    await updateCategoryStatus(categoryId, false);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Stream<CategoryEntity?> watchCategory(String categoryId) {
    return _remoteDataSource.watchCategory(categoryId).map((data) {
      if (data == null) return null;
      return CategoryModel.fromMap(data).toEntity();
    });
  }

  @override
  Stream<List<CategoryEntity>> watchCategories({bool? isActive, int? limit}) {
    return _remoteDataSource
        .watchCategories(isActive: isActive, limit: limit)
        .map((categoriesData) {
          return categoriesData
              .map((data) => CategoryModel.fromMap(data).toEntity())
              .toList();
        });
  }

  @override
  Stream<List<CategoryEntity>> watchActiveCategories({int? limit}) {
    return watchCategories(isActive: true, limit: limit);
  }
}
