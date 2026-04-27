import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUsecase {
  final AuthRepository _repository;
  const GetMeUsecase(this._repository);

  Future<User> call() => _repository.getMe();
}
