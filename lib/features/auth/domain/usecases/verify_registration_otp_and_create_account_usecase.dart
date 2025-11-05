import '../repositories/auth_repository.dart';

class VerifyRegistrationOTPAndCreateAccountUseCase {
  final AuthRepository repo;
  VerifyRegistrationOTPAndCreateAccountUseCase(this.repo);

  Future<String?> call({
    required String email,
    required String otpCode,
    required String password,
    required String name,
    String? phone,
  }) async {
    final isValid = await repo.verifyOTP(
      email: email,
      otp: otpCode,
      type: 'registration',
    );
    if (!isValid) return null;
    final uid = await repo.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (uid != null) {
      await repo.createUserDocument(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
      );
      await repo.clearOTP(email);
    }
    return uid;
  }
}
