sealed class EditProfileState {
  const EditProfileState();
}

final class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

final class EditProfileSubmitting extends EditProfileState {
  const EditProfileSubmitting();
}

final class EditProfileSuccess extends EditProfileState {
  final String name;
  const EditProfileSuccess(this.name);
}

final class EditProfileFailure extends EditProfileState {
  final String message;
  const EditProfileFailure(this.message);
}
