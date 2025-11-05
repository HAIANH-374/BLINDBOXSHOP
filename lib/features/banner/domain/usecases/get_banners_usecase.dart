import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class GetBannersUseCase {
  final BannerRepository _repository;

  GetBannersUseCase(this._repository);

  Future<List<BannerEntity>> call(GetBannersParams params) async {
    if (params.limit != null && params.limit! <= 0) {
      throw ArgumentError('Limit phải lớn hơn 0');
    }

    return await _repository.getBanners(
      isActive: params.isActive,
      limit: params.limit,
      orderBy: params.orderBy,
      descending: params.descending,
    );
  }
}

class GetBannersParams {
  final bool? isActive;
  final int? limit;
  final String? orderBy;
  final bool descending;

  const GetBannersParams({
    this.isActive,
    this.limit,
    this.orderBy,
    this.descending = false,
  });
}
