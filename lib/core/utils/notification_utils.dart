// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class NotificationUtils {
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showOutOfStock(String productName) {
    showWarning(
      'Sản phẩm "$productName" đã hết hàng',
      duration: const Duration(seconds: 4),
    );
  }

  static void showExceedStock(String productName, int availableStock) {
    showWarning(
      'Sản phẩm "$productName" chỉ còn $availableStock sản phẩm',
      duration: const Duration(seconds: 4),
    );
  }

  static void showAddToCartSuccess(String productName, int quantity) {
    showSuccess('Đã thêm $quantity sản phẩm "$productName" vào giỏ hàng');
  }

  static void showUpdateCartSuccess(String productName, int quantity) {
    showSuccess('Đã cập nhật "$productName" thành $quantity sản phẩm');
  }

  static void showRemoveFromCartSuccess(String productName) {
    showSuccess('Đã xóa "$productName" khỏi giỏ hàng');
  }

  static void showClearCartSuccess() {
    showSuccess('Đã xóa toàn bộ giỏ hàng');
  }

  static void showSyncSuccess() {
    showSuccess('Đã đồng bộ giỏ hàng thành công');
  }

  static void showNetworkError() {
    showError(
      'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      duration: const Duration(seconds: 5),
    );
  }

  static void showGenericError(String operation) {
    showError('Có lỗi xảy ra khi $operation. Vui lòng thử lại.');
  }

  static void showLoading(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void hideAll() {
    _scaffoldMessengerKey.currentState?.clearSnackBars();
  }
}
