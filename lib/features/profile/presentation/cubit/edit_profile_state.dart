enum EditProfileStatus {
  initial,
  loading,
  success,
  failure,
}

class EditProfileState {
  final EditProfileStatus status;
  final String? errorMessage;

  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.errorMessage,
  });

  bool get isLoading => status == EditProfileStatus.loading;
}