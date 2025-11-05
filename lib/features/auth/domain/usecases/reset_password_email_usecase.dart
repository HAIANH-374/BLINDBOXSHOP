import '../repositories/auth_repository.dart';

class ResetPasswordEmailUseCase {
  final AuthRepository repo;
  ResetPasswordEmailUseCase(this.repo);

  Future<void> call(String email) => repo.sendPasswordResetEmail(email);
}
