import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(String uid, Map<String, dynamic> data) async {
    return await repository.updateProfile(uid, data);
  }
}
