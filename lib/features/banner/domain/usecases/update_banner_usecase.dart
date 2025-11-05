import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class UpdateBannerUseCase {
  final BannerRepository _repository;

  UpdateBannerUseCase(this._repository);

  Future<void> call(BannerEntity banner) async {
    if (banner.id.isEmpty) {
      throw ArgumentError('Banner ID không được rỗng');
    }

    if (!banner.hasValidTitle) {
      throw ArgumentError('Tiêu đề banner không hợp lệ');
    }

    if (!banner.hasValidOrder) {
      throw ArgumentError('Thứ tự phải >= 0');
    }

    return await _repository.updateBanner(banner);
  }
}
