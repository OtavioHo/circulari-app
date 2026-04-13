import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repository;
  const LogoutUsecase(this._repository);

  Future<void> call() => _repository.logout();
}
