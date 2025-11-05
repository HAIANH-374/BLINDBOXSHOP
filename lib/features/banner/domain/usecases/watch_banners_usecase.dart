import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class WatchBannersUseCase {
  final BannerRepository _repository;

  WatchBannersUseCase(this._repository);

  Stream<List<BannerEntity>> call(WatchBannersParams params) {
    if (params.limit != null && params.limit! <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return _repository.watchBanners(
      isActive: params.isActive,
      limit: params.limit,
    );
  }
}

class WatchBannersParams {
  final bool? isActive;
  final int? limit;

  const WatchBannersParams({this.isActive, this.limit});
}
