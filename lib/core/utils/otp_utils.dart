import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import '../config/email_config.dart';

class OTPUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> sendOTPForRegistration(String email) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        throw Exception('Email này đã được sử dụng. Vui lòng chọn email khác.');
      }

      final otpCode = _generateOTPCode();

      await _firestore.collection('otp_codes').doc(email).set({
        'code': otpCode,
        'type': 'registration',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: 15)),
        ),
        'attempts': 0,
      });

      try {
        await _sendEmailOTP(email, otpCode, 'Đăng ký tài khoản');
        // ignore: empty_catches
      } catch (e) {}

      return true;
    } catch (e) {
      throw Exception('Lỗi gửi OTP: $e');
    }
  }

  static Future<bool> sendOTPForPasswordReset(String email) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Email này chưa được đăng ký. Vui lòng kiểm tra lại.');
      }

      final otpCode = _generateOTPCode();

      await _firestore.collection('otp_codes').doc(email).set({
        'code': otpCode,
        'type': 'password_reset',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: 15)),
        ),
        'attempts': 0,
      });

      try {
        await _sendEmailOTP(email, otpCode, 'Đặt lại mật khẩu');
        // ignore: empty_catches
      } catch (e) {}

      return true;
    } catch (e) {
      throw Exception('Lỗi gửi OTP: $e');
    }
  }

  static Future<bool> verifyOTP(
    String email,
    String otpCode, [
    String? type,
  ]) async {
    try {
      final doc = await _firestore.collection('otp_codes').doc(email).get();

      if (!doc.exists) {
        throw Exception('OTP không tồn tại hoặc đã hết hạn.');
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = data['attempts'] as int;

      // Kiểm tra số lần thử
      if (attempts >= 3) {
        throw Exception(
          'Bạn đã nhập sai OTP quá nhiều lần. Vui lòng yêu cầu OTP mới.',
        );
      }

      // Kiểm tra hết hạn
      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection('otp_codes').doc(email).delete();
        throw Exception('OTP đã hết hạn. Vui lòng yêu cầu OTP mới.');
      }

      // Kiểm tra OTP code
      if (storedCode != otpCode) {
        // Tăng số lần thử
        await _firestore.collection('otp_codes').doc(email).update({
          'attempts': FieldValue.increment(1),
        });
        throw Exception('OTP không đúng. Vui lòng kiểm tra lại.');
      }

      // Xóa OTP sau khi xác thực thành công
      await _firestore.collection('otp_codes').doc(email).delete();

      return true;
    } catch (e) {
      throw Exception('Lỗi xác thực OTP: $e');
    }
  }

  // Xóa OTP đã sử dụng
  static Future<void> clearOTP(String email) async {
    try {
      await _firestore.collection('otp_codes').doc(email).delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  // Reset mật khẩu với mã OTP
  static Future<bool> resetPasswordWithOTP(
    String email,
    String newPassword,
    String otpCode,
  ) async {
    try {
      final isValid = await verifyOTP(email, otpCode, 'password_reset');
      if (!isValid) {
        return false;
      }

      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: 'temp_password', // Cần mật khẩu cũ để reset
      );

      if (user.user != null) {
        await user.user!.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Lỗi reset mật khẩu: $e');
    }
  }

  static String _generateOTPCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final otp = (random % 900000 + 100000).toString();
    return otp;
  }

  static Future<void> _sendEmailOTP(
    String email,
    String otpCode,
    String type,
  ) async {
    try {
      final now = DateTime.now();
      final expires = now.add(const Duration(minutes: 15));
      final expiryTime =
          '${expires.day}/${expires.month}/${expires.year} ${expires.hour.toString().padLeft(2, '0')}:${expires.minute.toString().padLeft(2, '0')}';

      final bool isRegistration =
          type.toLowerCase() == 'registration' || type == 'Đăng ký tài khoản';

      final templateParams = {
        'email': email,
        'type': isRegistration ? 'xác nhận tài khoản' : 'đặt lại mật khẩu',
        'otp_code': otpCode,
        'expiry_time': expiryTime,
      };

      final templateId = _mapTypeToTemplateId(type);

      await emailjs.send(
        EmailConfig.serviceId,
        templateId,
        templateParams,
        emailjs.Options(
          publicKey: EmailConfig.publicKey,
          privateKey: EmailConfig.privateKey,
        ),
      );
    } catch (e) {
      throw Exception(
        'Có lỗi khi gửi otp: $e | serviceId=${EmailConfig.serviceId}, templateId=${_mapTypeToTemplateId(type)}',
      );
    }
  }
}

String _mapTypeToTemplateId(String type) {
  switch (type) {
    case 'Đăng ký tài khoản':
    case 'registration':
      return EmailConfig.templateOtpRegistrationId;
    case 'Đặt lại mật khẩu':
    case 'password_reset':
      return EmailConfig.templateOtpPasswordResetId;
    case 'order_confirmation':
      return EmailConfig.templateOrderNotificationId;
    default:
      return EmailConfig.templateId;
  }
}
