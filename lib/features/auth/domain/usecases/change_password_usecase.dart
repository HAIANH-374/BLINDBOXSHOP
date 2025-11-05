import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repo;
  ChangePasswordUseCase(this.repo);

  Future<bool> call(String currentPassword, String newPassword) {
    return repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
