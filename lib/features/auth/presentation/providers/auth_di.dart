import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_auth_user_data_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/send_registration_otp_usecase.dart';
import '../../domain/usecases/verify_registration_otp_and_create_account_usecase.dart';
import '../../domain/usecases/send_password_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_email_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final getAuthUserDataUseCaseProvider = Provider<GetAuthUserDataUseCase>((ref) {
  return GetAuthUserDataUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.read(authRepositoryProvider));
});

final sendRegistrationOTPUseCaseProvider = Provider<SendRegistrationOTPUseCase>(
  (ref) {
    return SendRegistrationOTPUseCase(ref.read(authRepositoryProvider));
  },
);

final verifyRegistrationOTPAndCreateAccountUseCaseProvider =
    Provider<VerifyRegistrationOTPAndCreateAccountUseCase>((ref) {
      return VerifyRegistrationOTPAndCreateAccountUseCase(
        ref.read(authRepositoryProvider),
      );
    });

final sendPasswordResetOTPUseCaseProvider =
    Provider<SendPasswordResetOTPUseCase>((ref) {
      return SendPasswordResetOTPUseCase(ref.read(authRepositoryProvider));
    });

final resetPasswordEmailUseCaseProvider = Provider<ResetPasswordEmailUseCase>((
  ref,
) {
  return ResetPasswordEmailUseCase(ref.read(authRepositoryProvider));
});
