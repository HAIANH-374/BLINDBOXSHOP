import '../repositories/auth_repository.dart';

class SendPasswordResetOTPUseCase {
  final AuthRepository repo;
  SendPasswordResetOTPUseCase(this.repo);

  Future<bool> call(String email) => repo.sendOTPForPasswordReset(email);
}
