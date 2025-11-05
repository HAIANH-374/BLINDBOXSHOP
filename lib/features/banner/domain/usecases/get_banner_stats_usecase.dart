import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class GetBannerStatsUseCase {
  final BannerRepository _repository;

  GetBannerStatsUseCase(this._repository);

  Future<BannerStatsEntity> call() async {
    return await _repository.getBannerStats();
  }
}
