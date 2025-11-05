import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class GetActiveBannersUseCase {
  final BannerRepository _repository;

  GetActiveBannersUseCase(this._repository);

  Future<List<BannerEntity>> call({int? limit}) async {
    if (limit != null && limit <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return await _repository.getActiveBanners(limit: limit);
  }
}
