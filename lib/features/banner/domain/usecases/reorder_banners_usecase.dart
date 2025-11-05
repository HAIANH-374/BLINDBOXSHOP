import '../repositories/banner_repository.dart';

class ReorderBannersUseCase {
  final BannerRepository _repository;

  ReorderBannersUseCase(this._repository);

  Future<void> call(List<String> bannerIds) async {
    if (bannerIds.isEmpty) {
      throw ArgumentError('Danh sách bannerIds không được rỗng');
    }

    final uniqueIds = bannerIds.toSet();
    if (uniqueIds.length != bannerIds.length) {
      throw ArgumentError('Danh sách bannerIds có ID trùng lặp');
    }

    return await _repository.reorderBanners(bannerIds);
  }
}
