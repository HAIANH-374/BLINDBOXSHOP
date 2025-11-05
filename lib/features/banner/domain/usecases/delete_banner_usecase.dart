import '../repositories/banner_repository.dart';

class DeleteBannerUseCase {
  final BannerRepository _repository;

  DeleteBannerUseCase(this._repository);

  Future<void> call(String bannerId) async {
    if (bannerId.isEmpty) {
      throw ArgumentError('Banner ID không được rỗng');
    }

    return await _repository.deleteBanner(bannerId);
  }
}
