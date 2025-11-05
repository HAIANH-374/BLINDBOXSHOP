import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/otp_utils.dart';
import '../../../../core/utils/notification_utils.dart';
import '../providers/auth_provider.dart';

class OTPVerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String type;
  final String? password;
  final String? newPassword;
  final String? name;
  final String? phone;

  const OTPVerificationPage({
    super.key,
    required this.email,
    required this.type,
    this.password,
    this.newPassword,
    this.name,
    this.phone,
  });

  @override
  ConsumerState<OTPVerificationPage> createState() =>
      _OTPVerificationPageState();
}

class _OTPVerificationPageState extends ConsumerState<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  int _countdown = 900; // 15 phút
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 900;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _canResend = true;
          }
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otpCode = _getOTPCode();
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ 6 số OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.type == 'registration') {
        final authNotifier = ref.read(authProvider.notifier);
        final success = await authNotifier.verifyOTPAndCreateAccount(
          email: widget.email,
          otpCode: otpCode,
          password: widget.password ?? 'temp123456',
          name: widget.name ?? 'Người dùng',
          phone: widget.phone,
        );

        if (success) {
          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          setState(() {
            _errorMessage = 'Tạo tài khoản thất bại';
          });
        }
      } else if (widget.type == 'password_reset') {
        final isValid = await OTPUtils.verifyOTP(
          widget.email,
          otpCode,
          'password_reset',
        );

        if (isValid) {
          await OTPUtils.resetPasswordWithOTP(
            widget.email,
            widget.newPassword!,
            otpCode,
          );

          if (mounted) {
            _showPasswordResetSuccessDialog();
          }
        } else {
          setState(() {
            _errorMessage = 'Mã OTP không đúng hoặc đã hết hạn';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.type == 'registration') {
        await OTPUtils.sendOTPForRegistration(widget.email);
      } else {
        await OTPUtils.sendOTPForPasswordReset(widget.email);
      }

      _startCountdown();

      if (mounted) {
        NotificationUtils.showSuccess('Đã gửi lại OTP đến ${widget.email}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Đăng ký thành công!'),
        content: Text('Tài khoản của bạn đã được tạo. Vui lòng đăng nhập.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Đổi mật khẩu thành công!'),
        content: Text(
          'Mật khẩu của bạn đã được cập nhật. Vui lòng đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Xác thực OTP',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và hướng dẫn
            Text(
              'Nhập mã OTP',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Chúng tôi đã gửi mã xác thực 6 số đến\n${widget.email}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // Hàng nhập OTP (6 ô)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 45.w,
                  height: 55.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _errorMessage != null
                          ? AppColors.error
                          : AppColors.lightGrey,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.white,
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _onOTPChanged(index, value),
                  ),
                );
              }),
            ),

            SizedBox(height: 16.h),

            // Thông báo lỗi
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  // ignore: deprecated_member_use
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                ),
              ),

            SizedBox(height: 24.h),

            // Nút xác thực OTP
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Xác thực',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 24.h),

            // Khu vực gửi lại OTP
            Center(
              child: Column(
                children: [
                  Text(
                    'Không nhận được mã?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (_canResend)
                    // Nút gửi lại mã
                    TextButton(
                      onPressed: _isLoading ? null : _resendOTP,
                      child: Text(
                        'Gửi lại mã',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    // Đếm ngược gửi lại
                    Text(
                      'Gửi lại sau ${_countdown}s',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
