import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;
  const RegisterUsecase(this._repository);

  Future<User> call({
    required String email,
    required String password,
    required String name,
  }) =>
      _repository.register(email: email, password: password, name: name);
}
