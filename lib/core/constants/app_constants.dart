class AppConstants {
  // Thông tin ứng dụng
  static const String appName = 'Blind Box Shop';

  // API
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Xác thực
  static const int minPasswordLength = 6;

  // Trạng thái đơn hàng
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipping = 'shipping';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Phương thức thanh toán
  static const String paymentCod = 'cod';
  static const String paymentBankTransfer = 'bank_transfer';
  static const String paymentMomo = 'momo';
  static const String paymentZaloPay = 'zalopay';
}
