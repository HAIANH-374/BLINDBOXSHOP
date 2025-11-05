import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repo;
  RegisterUseCase(this.repo);

  Future<String?> call(String email, String password) {
    return repo.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
