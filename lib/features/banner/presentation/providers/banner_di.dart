import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/banner_remote_datasource.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/usecases/create_banner_usecase.dart';
import '../../domain/usecases/delete_banner_usecase.dart';
import '../../domain/usecases/get_active_banners_usecase.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/get_banner_stats_usecase.dart';
import '../../domain/usecases/reorder_banners_usecase.dart';
import '../../domain/usecases/update_banner_status_usecase.dart';
import '../../domain/usecases/update_banner_usecase.dart';
import '../../domain/usecases/watch_banners_usecase.dart';

final firestoreBannerProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final bannerRemoteDataSourceProvider = Provider<BannerRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreBannerProvider);
  return BannerRemoteDataSourceImpl(firestore);
});

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final remoteDataSource = ref.watch(bannerRemoteDataSourceProvider);
  return BannerRepositoryImpl(remoteDataSource);
});

final getBannersUseCaseProvider = Provider<GetBannersUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return GetBannersUseCase(repository);
});

final getActiveBannersUseCaseProvider = Provider<GetActiveBannersUseCase>((
  ref,
) {
  final repository = ref.watch(bannerRepositoryProvider);
  return GetActiveBannersUseCase(repository);
});

final createBannerUseCaseProvider = Provider<CreateBannerUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return CreateBannerUseCase(repository);
});

final updateBannerUseCaseProvider = Provider<UpdateBannerUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return UpdateBannerUseCase(repository);
});

final deleteBannerUseCaseProvider = Provider<DeleteBannerUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return DeleteBannerUseCase(repository);
});

final updateBannerStatusUseCaseProvider = Provider<UpdateBannerStatusUseCase>((
  ref,
) {
  final repository = ref.watch(bannerRepositoryProvider);
  return UpdateBannerStatusUseCase(repository);
});

final reorderBannersUseCaseProvider = Provider<ReorderBannersUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return ReorderBannersUseCase(repository);
});

final getBannerStatsUseCaseProvider = Provider<GetBannerStatsUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return GetBannerStatsUseCase(repository);
});

final watchBannersUseCaseProvider = Provider<WatchBannersUseCase>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return WatchBannersUseCase(repository);
});
