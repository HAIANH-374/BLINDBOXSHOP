import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repo;
  SignInUseCase(this.repo);

  Future<String?> call(String email, String password) {
    return repo.signInWithEmailAndPassword(email: email, password: password);
  }
}
