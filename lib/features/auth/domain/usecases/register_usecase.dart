import 'package:circulari/features/auth/domain/entities/user.dart';
import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';

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
