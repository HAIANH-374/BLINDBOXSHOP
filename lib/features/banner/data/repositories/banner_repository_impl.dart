import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/banner_remote_datasource.dart';
import '../models/banner_model.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource _remoteDataSource;

  BannerRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<BannerEntity>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    final bannersData = await _remoteDataSource.getBanners(
      isActive: isActive,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );

    return bannersData
        .map((data) => BannerModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<BannerEntity?> getBannerById(String bannerId) async {
    final bannerData = await _remoteDataSource.getBannerById(bannerId);
    if (bannerData == null) return null;
    return BannerModel.fromMap(bannerData).toEntity();
  }

  @override
  Future<List<BannerEntity>> getActiveBanners({int? limit}) async {
    final bannersData = await _remoteDataSource.getActiveBanners(limit: limit);
    return bannersData
        .map((data) => BannerModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<BannerEntity>> searchBanners(String query) async {
    final bannersData = await _remoteDataSource.searchBanners(query);
    return bannersData
        .map((data) => BannerModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<BannerEntity>> getBannersByLinkType(String linkType) async {
    final bannersData = await _remoteDataSource.getBannersByLinkType(linkType);
    return bannersData
        .map((data) => BannerModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<List<BannerEntity>> getBannersByLinkValue(String linkValue) async {
    final bannersData = await _remoteDataSource.getBannersByLinkValue(
      linkValue,
    );
    return bannersData
        .map((data) => BannerModel.fromMap(data).toEntity())
        .toList();
  }

  @override
  Future<BannerEntity?> getNextBanner(int currentOrder) async {
    final bannerData = await _remoteDataSource.getNextBanner(currentOrder);
    if (bannerData == null) return null;
    return BannerModel.fromMap(bannerData).toEntity();
  }

  @override
  Future<BannerEntity?> getPreviousBanner(int currentOrder) async {
    final bannerData = await _remoteDataSource.getPreviousBanner(currentOrder);
    if (bannerData == null) return null;
    return BannerModel.fromMap(bannerData).toEntity();
  }

  @override
  Future<BannerStatsEntity> getBannerStats() async {
    final statsData = await _remoteDataSource.getBannerStats();
    return BannerStatsModel.fromMap(statsData).toEntity();
  }

  @override
  Future<BannerEntity> createBanner(BannerEntity banner) async {
    final bannerModel = BannerModel.fromEntity(banner);
    final newId = await _remoteDataSource.createBanner(
      bannerModel.toFirestore(),
    );
    return bannerModel.copyWith(id: newId).toEntity();
  }

  @override
  Future<void> updateBanner(BannerEntity banner) async {
    final bannerModel = BannerModel.fromEntity(banner);
    await _remoteDataSource.updateBanner(banner.id, bannerModel.toFirestore());
  }

  @override
  Future<void> updateBannerStatus(String bannerId, bool isActive) async {
    await _remoteDataSource.updateBannerStatus(bannerId, isActive);
  }

  @override
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    await _remoteDataSource.updateBannerOrder(bannerId, newOrder);
  }

  @override
  Future<void> reorderBanners(List<String> bannerIds) async {
    await _remoteDataSource.reorderBanners(bannerIds);
  }

  @override
  Future<void> activateBanner(String bannerId) async {
    await updateBannerStatus(bannerId, true);
  }

  @override
  Future<void> deactivateBanner(String bannerId) async {
    await updateBannerStatus(bannerId, false);
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    await _remoteDataSource.deleteBanner(bannerId);
  }

  @override
  Stream<BannerEntity?> watchBanner(String bannerId) {
    return _remoteDataSource.watchBanner(bannerId).map((data) {
      if (data == null) return null;
      return BannerModel.fromMap(data).toEntity();
    });
  }

  @override
  Stream<List<BannerEntity>> watchBanners({bool? isActive, int? limit}) {
    return _remoteDataSource.watchBanners(isActive: isActive, limit: limit).map(
      (bannersData) {
        return bannersData
            .map((data) => BannerModel.fromMap(data).toEntity())
            .toList();
      },
    );
  }

  @override
  Stream<List<BannerEntity>> watchActiveBanners({int? limit}) {
    return watchBanners(isActive: true, limit: limit);
  }
}
