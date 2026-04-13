import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;
  const LoginUsecase(this._repository);

  Future<void> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
