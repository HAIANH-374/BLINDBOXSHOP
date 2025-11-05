import '../entities/banner_entity.dart';

/// Repository interface cho Banner trong Domain Layer
abstract class BannerRepository {
  // READ Operations
  Future<List<BannerEntity>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });

  Future<BannerEntity?> getBannerById(String bannerId);

  Future<List<BannerEntity>> getActiveBanners({int? limit});

  Future<List<BannerEntity>> searchBanners(String query);

  Future<List<BannerEntity>> getBannersByLinkType(String linkType);

  Future<List<BannerEntity>> getBannersByLinkValue(String linkValue);

  Future<BannerEntity?> getNextBanner(int currentOrder);

  Future<BannerEntity?> getPreviousBanner(int currentOrder);

  Future<BannerStatsEntity> getBannerStats();

  // CREATE Operations
  Future<BannerEntity> createBanner(BannerEntity banner);

  // UPDATE Operations
  Future<void> updateBanner(BannerEntity banner);

  Future<void> updateBannerStatus(String bannerId, bool isActive);

  Future<void> updateBannerOrder(String bannerId, int newOrder);

  Future<void> reorderBanners(List<String> bannerIds);

  Future<void> activateBanner(String bannerId);

  Future<void> deactivateBanner(String bannerId);

  // DELETE Operations
  Future<void> deleteBanner(String bannerId);

  // STREAM Operations
  Stream<BannerEntity?> watchBanner(String bannerId);

  Stream<List<BannerEntity>> watchBanners({bool? isActive, int? limit});

  Stream<List<BannerEntity>> watchActiveBanners({int? limit});
}
