import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../../../core/utils/notification_utils.dart';
import 'auth_di.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final User? firebaseUser;
  final AuthUser? authUser;
  final bool isLoading;
  final String? error;

  AuthState({
    this.firebaseUser,
    this.authUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Object? firebaseUser = _undefined,
    Object? authUser = _undefined,
    bool? isLoading,
    Object? error = _undefined,
  }) {
    return AuthState(
      firebaseUser: firebaseUser == _undefined
          ? this.firebaseUser
          : firebaseUser as User?,
      authUser: authUser == _undefined ? this.authUser : authUser as AuthUser?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
    );
  }
}

const _undefined = Object();

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(AuthState()) {
    _init();
  }

  void _init() async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser != null) {
      await _loadAuthUser(currentUser.uid);
    }
    ref.read(authRepositoryProvider).authStateChanges().listen((
      User? user,
    ) async {
      if (user != null) {
        await _loadAuthUser(user.uid);
      } else {
        state = state.copyWith(firebaseUser: null, authUser: null);
      }
    });
  }

  Future<void> _loadAuthUser(String uid) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final authUser = await ref.read(getAuthUserDataUseCaseProvider)(uid);

      if (authUser == null) {
        state = state.copyWith(
          firebaseUser: ref.read(authRepositoryProvider).currentUser,
          authUser: null,
          isLoading: false,
          error: 'User data not found',
        );
      } else {
        state = state.copyWith(
          firebaseUser: ref.read(authRepositoryProvider).currentUser,
          authUser: authUser,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        firebaseUser: ref.read(authRepositoryProvider).currentUser,
        authUser: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final uid = await ref.read(signInUseCaseProvider)(email, password);
      if (uid != null) {
        await _loadAuthUser(uid);
        NotificationUtils.showSuccess('Đăng nhập thành công!');
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Đăng nhập thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<bool> sendOTPForRegistration({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final success = await ref.read(sendRegistrationOTPUseCaseProvider)(email);

      if (success) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOTPAndCreateAccount({
    required String email,
    required String otpCode,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final uid =
          await ref.read(verifyRegistrationOTPAndCreateAccountUseCaseProvider)(
            email: email,
            otpCode: otpCode,
            password: password,
            name: name,
            phone: phone,
          );

      if (uid != null) {
        await _loadAuthUser(uid);
        NotificationUtils.showSuccess('Tạo tài khoản thành công!');
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final uid = await ref.read(registerUseCaseProvider)(email, password);
      if (uid != null) {
        await ref
            .read(authRepositoryProvider)
            .createUserDocument(
              uid: uid,
              email: email,
              name: name,
              phone: phone,
            );
        await _loadAuthUser(uid);
        NotificationUtils.showSuccess('Tạo tài khoản thành công!');
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Tạo tài khoản thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(signOutUseCaseProvider)();
      state = AuthState();
      NotificationUtils.showInfo('Đã đăng xuất thành công!');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      NotificationUtils.showError('Đăng xuất thất bại: ${e.toString()}');
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (state.firebaseUser == null) return false;

      state = state.copyWith(isLoading: true, error: null);

      final ok = await ref.read(changePasswordUseCaseProvider)(
        currentPassword,
        newPassword,
      );

      state = state.copyWith(isLoading: false);
      if (ok) {
        NotificationUtils.showSuccess('Đổi mật khẩu thành công!');
      } else {
        NotificationUtils.showError('Đổi mật khẩu thất bại');
      }
      return ok;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Đổi mật khẩu thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await ref.read(resetPasswordEmailUseCaseProvider)(email);

      state = state.copyWith(isLoading: false);
      NotificationUtils.showSuccess('Đã gửi email reset mật khẩu!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError(
        'Gửi email reset mật khẩu thất bại: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> sendRegistrationOTP(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await ref.read(sendRegistrationOTPUseCaseProvider)(email);

      state = state.copyWith(isLoading: false);
      if (result) {
        NotificationUtils.showSuccess('Đã gửi OTP đến email của bạn!');
      } else {
        NotificationUtils.showError('Gửi OTP thất bại!');
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Gửi OTP thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<bool> sendPasswordResetOTP(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await ref.read(sendPasswordResetOTPUseCaseProvider)(email);

      state = state.copyWith(isLoading: false);
      if (result) {
        NotificationUtils.showSuccess('Đã gửi OTP reset mật khẩu!');
      } else {
        NotificationUtils.showError('Gửi OTP thất bại!');
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Gửi OTP thất bại: ${e.toString()}');
      return false;
    }
  }
}
