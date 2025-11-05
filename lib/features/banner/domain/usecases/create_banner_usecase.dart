import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class CreateBannerUseCase {
  final BannerRepository _repository;

  CreateBannerUseCase(this._repository);

  Future<BannerEntity> call(BannerEntity banner) async {
    if (!banner.hasValidTitle) {
      throw ArgumentError('Tiêu đề banner không hợp lệ');
    }

    if (!banner.hasImage) {
      throw ArgumentError('Banner phải có hình ảnh');
    }

    if (!banner.hasValidOrder) {
      throw ArgumentError('Thứ tự phải >= 0');
    }

    return await _repository.createBanner(banner);
  }
}
