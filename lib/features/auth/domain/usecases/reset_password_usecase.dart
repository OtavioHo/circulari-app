import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository _repository;
  const ResetPasswordUsecase(this._repository);

  Future<void> call({
    required String email,
    required String resetToken,
    required String newPassword,
  }) =>
      _repository.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
}
