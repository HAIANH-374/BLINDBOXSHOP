import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/get_user_cart_usecase.dart';
import '../../domain/usecases/add_item_to_cart_usecase.dart';
import '../../domain/usecases/update_item_quantity_usecase.dart';
import '../../domain/usecases/remove_item_from_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CartRemoteDataSourceImpl(firestore: firestore);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final remoteDataSource = ref.watch(cartRemoteDataSourceProvider);
  return CartRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getUserCartUseCaseProvider = Provider<GetUserCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return GetUserCartUseCase(repository);
});

final addItemToCartUseCaseProvider = Provider<AddItemToCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddItemToCartUseCase(repository);
});

final updateItemQuantityUseCaseProvider = Provider<UpdateItemQuantityUseCase>((
  ref,
) {
  final repository = ref.watch(cartRepositoryProvider);
  return UpdateItemQuantityUseCase(repository);
});

final removeItemFromCartUseCaseProvider = Provider<RemoveItemFromCartUseCase>((
  ref,
) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveItemFromCartUseCase(repository);
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ClearCartUseCase(repository);
});
