import '../entities/category_entity.dart';

abstract class CategoryRepository {
  
  Future<List<CategoryEntity>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });

  Future<CategoryEntity?> getCategoryById(String categoryId);

  Future<List<CategoryEntity>> getActiveCategories({int? limit});

  Future<CategoryEntity?> getCategoryByName(String name);

  Future<List<CategoryEntity>> searchCategories(String query);

  Future<CategoryEntity?> getNextCategory(int currentOrder);

  Future<CategoryEntity?> getPreviousCategory(int currentOrder);

  Future<List<String>> getCategoryNames();

  Future<CategoryStatsEntity> getCategoryStats();

  Future<bool> categoryExists(String name);

  
  Future<CategoryEntity> createCategory(CategoryEntity category);

  Future<void> updateCategory(CategoryEntity category);

  Future<void> updateCategoryStatus(String categoryId, bool isActive);

  Future<void> updateCategoryOrder(String categoryId, int newOrder);

  Future<void> reorderCategories(List<String> categoryIds);

  Future<void> activateCategory(String categoryId);

  Future<void> deactivateCategory(String categoryId);

  Future<void> deleteCategory(String categoryId);

  Stream<CategoryEntity?> watchCategory(String categoryId);

  Stream<List<CategoryEntity>> watchCategories({bool? isActive, int? limit});

  Stream<List<CategoryEntity>> watchActiveCategories({int? limit});
}
