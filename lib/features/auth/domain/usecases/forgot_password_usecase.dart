import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository _repository;
  const ForgotPasswordUsecase(this._repository);

  Future<void> call({required String email}) =>
      _repository.forgotPassword(email: email);
}
