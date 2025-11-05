import 'package:emailjs/emailjs.dart' as emailjs;
import '../../features/order/data/models/order_model.dart';
import '../config/email_config.dart';

class EmailUtils {
  static Future<bool> sendOrderNotificationEmail({
    required String userEmail,
    required OrderModel order,
    required String userName,
  }) async {
    try {
      final templateParams = _createOrderNotificationParams(
        order: order,
        userName: userName,
        userEmail: userEmail,
      );

      await emailjs.send(
        EmailConfig.serviceId,
        EmailConfig.templateOrderNotificationId,
        templateParams,
        emailjs.Options(
          publicKey: EmailConfig.publicKey,
          privateKey: EmailConfig.privateKey,
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> _createOrderNotificationParams({
    required OrderModel order,
    required String userName,
    required String userEmail,
  }) {
    final orders = order.items
        .map(
          (item) => {
            'name': item.productName,
            'units': item.quantity,
            'price': item.price.toStringAsFixed(0),
            'image_url': item.productImage,
          },
        )
        .toList();

    return {
      'order_id': order.orderNumber,
      'email': userEmail,
      'orders': orders,
      'cost': {
        'shipping': order.shippingFee.toStringAsFixed(0),
        'tax': '0',
        'total': order.totalAmount.toStringAsFixed(0),
      },
    };
  }
}
