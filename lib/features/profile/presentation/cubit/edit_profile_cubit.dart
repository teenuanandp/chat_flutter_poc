import 'package:chat_flutter_poc/features/authentication/data/models/auth_user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/update_profile_usecase.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;

  EditProfileCubit({
    required this.updateProfileUseCase,
  }) : super(const EditProfileState());

  Future<AuthUserModel?> updateProfile({
    required String displayName,
    required String about,
  }) async {
    emit(
      const EditProfileState(
        status: EditProfileStatus.loading,
      ),
    );

    try {
      final profile = await updateProfileUseCase(
        displayName: displayName,
        about: about,
      );

      emit(
        const EditProfileState(
          status: EditProfileStatus.success,
        ),
      );

      return profile;
    } catch (e) {
      emit(
        EditProfileState(
          status: EditProfileStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );

      return null;
    }
  }
}