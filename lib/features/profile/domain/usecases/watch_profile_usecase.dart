import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class WatchProfileUseCase {
  final ProfileRepository repository;

  WatchProfileUseCase(this.repository);

  Stream<UserProfile?> call(String uid) {
    return repository.watchProfile(uid);
  }
}
