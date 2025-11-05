import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_user_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/get_orders_by_status_usecase.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../../domain/usecases/confirm_order_usecase.dart';
import '../../domain/usecases/start_preparing_order_usecase.dart';
import '../../domain/usecases/start_shipping_order_usecase.dart';
import '../../domain/usecases/complete_delivery_usecase.dart';
import '../../domain/usecases/complete_order_usecase.dart';
import '../../domain/usecases/update_payment_info_usecase.dart';
import '../../domain/usecases/get_order_by_number_usecase.dart';
import '../../domain/usecases/get_all_orders_usecase.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return OrderRemoteDataSourceImpl(firestore: firestore);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: remoteDataSource);
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrderUseCase(repository);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderByIdUseCase(repository);
});

final getUserOrdersUseCaseProvider = Provider<GetUserOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetUserOrdersUseCase(repository);
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatusUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdateOrderStatusUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrderUseCase(repository);
});

final getOrdersByStatusUseCaseProvider = Provider<GetOrdersByStatusUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrdersByStatusUseCase(repository);
});

final searchOrdersUseCaseProvider = Provider<SearchOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return SearchOrdersUseCase(repository);
});

final confirmOrderUseCaseProvider = Provider<ConfirmOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return ConfirmOrderUseCase(repository);
});

final startPreparingOrderUseCaseProvider = Provider<StartPreparingOrderUseCase>(
  (ref) {
    final repository = ref.watch(orderRepositoryProvider);
    return StartPreparingOrderUseCase(repository);
  },
);

final startShippingOrderUseCaseProvider = Provider<StartShippingOrderUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return StartShippingOrderUseCase(repository);
});

final completeDeliveryUseCaseProvider = Provider<CompleteDeliveryUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return CompleteDeliveryUseCase(repository);
});

final completeOrderUseCaseProvider = Provider<CompleteOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CompleteOrderUseCase(repository);
});

final updatePaymentInfoUseCaseProvider = Provider<UpdatePaymentInfoUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdatePaymentInfoUseCase(repository);
});

final getOrderByNumberUseCaseProvider = Provider<GetOrderByNumberUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderByNumberUseCase(repository);
});

final getAllOrdersUseCaseProvider = Provider<GetAllOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetAllOrdersUseCase(repository);
});
