import '../repositories/auth_repository.dart';

class SendRegistrationOTPUseCase {
  final AuthRepository repo;
  SendRegistrationOTPUseCase(this.repo);

  Future<bool> call(String email) => repo.sendOTPForRegistration(email);
}
