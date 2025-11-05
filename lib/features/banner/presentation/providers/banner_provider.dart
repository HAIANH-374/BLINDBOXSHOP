import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/banner_entity.dart';
import '../../domain/usecases/create_banner_usecase.dart';
import '../../domain/usecases/delete_banner_usecase.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/reorder_banners_usecase.dart';
import '../../domain/usecases/update_banner_status_usecase.dart';
import '../../domain/usecases/update_banner_usecase.dart';
import '../../domain/usecases/watch_banners_usecase.dart';
import 'banner_di.dart';

final bannersProvider =
    FutureProvider.family<List<BannerEntity>, GetBannersParams>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(getBannersUseCaseProvider);
      return await useCase(params);
    });

final activeBannersProvider = FutureProvider.family<List<BannerEntity>, int?>((
  ref,
  limit,
) async {
  final useCase = ref.watch(getActiveBannersUseCaseProvider);
  return await useCase(limit: limit);
});

final bannerStatsProvider = FutureProvider<BannerStatsEntity>((ref) async {
  final useCase = ref.watch(getBannerStatsUseCaseProvider);
  return await useCase();
});

final watchBannersProvider =
    StreamProvider.family<List<BannerEntity>, WatchBannersParams>((
      ref,
      params,
    ) {
      final useCase = ref.watch(watchBannersUseCaseProvider);
      return useCase(params);
    });

final watchActiveBannersProvider =
    StreamProvider.family<List<BannerEntity>, int?>((ref, limit) {
      final params = WatchBannersParams(isActive: true, limit: limit);
      final useCase = ref.watch(watchBannersUseCaseProvider);
      return useCase(params);
    });

final bannerNotifierProvider =
    StateNotifierProvider<BannerNotifier, AsyncValue<void>>(
      (ref) => BannerNotifier(
        createBannerUseCase: ref.watch(createBannerUseCaseProvider),
        updateBannerUseCase: ref.watch(updateBannerUseCaseProvider),
        deleteBannerUseCase: ref.watch(deleteBannerUseCaseProvider),
        updateBannerStatusUseCase: ref.watch(updateBannerStatusUseCaseProvider),
        reorderBannersUseCase: ref.watch(reorderBannersUseCaseProvider),
      ),
    );

class BannerNotifier extends StateNotifier<AsyncValue<void>> {
  final CreateBannerUseCase _createBannerUseCase;
  final UpdateBannerUseCase _updateBannerUseCase;
  final DeleteBannerUseCase _deleteBannerUseCase;
  final UpdateBannerStatusUseCase _updateBannerStatusUseCase;
  final ReorderBannersUseCase _reorderBannersUseCase;

  BannerNotifier({
    required CreateBannerUseCase createBannerUseCase,
    required UpdateBannerUseCase updateBannerUseCase,
    required DeleteBannerUseCase deleteBannerUseCase,
    required UpdateBannerStatusUseCase updateBannerStatusUseCase,
    required ReorderBannersUseCase reorderBannersUseCase,
  }) : _createBannerUseCase = createBannerUseCase,
       _updateBannerUseCase = updateBannerUseCase,
       _deleteBannerUseCase = deleteBannerUseCase,
       _updateBannerStatusUseCase = updateBannerStatusUseCase,
       _reorderBannersUseCase = reorderBannersUseCase,
       super(const AsyncValue.data(null));

  Future<BannerEntity?> createBanner(BannerEntity banner) async {
    state = const AsyncValue.loading();
    try {
      final newBanner = await _createBannerUseCase(banner);
      state = const AsyncValue.data(null);
      return newBanner;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<bool> updateBanner(BannerEntity banner) async {
    state = const AsyncValue.loading();
    try {
      await _updateBannerUseCase(banner);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteBanner(String bannerId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteBannerUseCase(bannerId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateBannerStatus(String bannerId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      final params = UpdateBannerStatusParams(
        bannerId: bannerId,
        isActive: isActive,
      );
      await _updateBannerStatusUseCase(params);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> activateBanner(String bannerId) async {
    return await updateBannerStatus(bannerId, true);
  }

  Future<bool> deactivateBanner(String bannerId) async {
    return await updateBannerStatus(bannerId, false);
  }

  Future<bool> reorderBanners(List<String> bannerIds) async {
    state = const AsyncValue.loading();
    try {
      await _reorderBannersUseCase(bannerIds);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
