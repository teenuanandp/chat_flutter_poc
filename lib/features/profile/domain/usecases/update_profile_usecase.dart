import 'package:chat_flutter_poc/features/authentication/data/models/auth_user_model.dart';

import '../../data/storage/profile_local_storage.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  final ProfileLocalStorage localStorage;

  UpdateProfileUseCase({
    required this.repository,
    required this.localStorage,
  });

  Future<AuthUserModel> call({
    required String displayName,
    required String about,
  }) async {
    final updatedProfile = await repository.updateProfile(
      displayName: displayName,
      about: about,
    );

    await localStorage.saveProfile(updatedProfile);

    return updatedProfile;
  }
}