import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../../../core/utils/notification_utils.dart';
import 'profile_di.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref);
});

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(ProfileState());

  Future<void> loadProfile(String uid) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final profile = await ref.read(getProfileUseCaseProvider)(uid);

      if (profile == null) {
        state = state.copyWith(isLoading: false, error: 'Profile not found');
      } else {
        state = state.copyWith(profile: profile, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Lỗi khi tải thông tin: ${e.toString()}');
    }
  }

  void watchProfile(String uid) {
    ref.read(watchProfileUseCaseProvider)(uid).listen((profile) {
      state = state.copyWith(profile: profile);
    });
  }

  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }

      if (updateData.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      await ref.read(updateProfileUseCaseProvider)(uid, updateData);
      await loadProfile(uid);

      NotificationUtils.showSuccess('Cập nhật thông tin thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Cập nhật thất bại: ${e.toString()}');
      return false;
    }
  }

  Future<bool> uploadAvatar({
    required String uid,
    required String imagePath,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await ref.read(uploadAvatarUseCaseProvider)(uid, imagePath);
      await loadProfile(uid);

      NotificationUtils.showSuccess('Cập nhật ảnh đại diện thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationUtils.showError('Cập nhật ảnh thất bại: ${e.toString()}');
      return false;
    }
  }

  void clearProfile() {
    state = ProfileState();
  }
}
