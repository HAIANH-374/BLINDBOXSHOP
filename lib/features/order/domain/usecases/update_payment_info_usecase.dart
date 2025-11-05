import '../repositories/order_repository.dart';

/// UseCase: Cập nhật thông tin thanh toán
class UpdatePaymentInfoUseCase {
  final OrderRepository repository;

  UpdatePaymentInfoUseCase(this.repository);

  Future<void> call(
    String orderId, {
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentStatus,
    String? paymentTransactionId,
  }) async {
    if (orderId.isEmpty) {
      throw ArgumentError('Order ID không được để trống');
    }

    return await repository.updatePaymentInfo(
      orderId,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      paymentStatus: paymentStatus,
      paymentTransactionId: paymentTransactionId,
    );
  }
}
