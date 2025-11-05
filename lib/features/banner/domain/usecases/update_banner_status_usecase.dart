import '../repositories/banner_repository.dart';

class UpdateBannerStatusUseCase {
  final BannerRepository _repository;

  UpdateBannerStatusUseCase(this._repository);

  Future<void> call(UpdateBannerStatusParams params) async {
    if (params.bannerId.isEmpty) {
      throw ArgumentError('Banner ID không được rỗng');
    }

    return await _repository.updateBannerStatus(
      params.bannerId,
      params.isActive,
    );
  }
}

class UpdateBannerStatusParams {
  final String bannerId;
  final bool isActive;

  const UpdateBannerStatusParams({
    required this.bannerId,
    required this.isActive,
  });
}
