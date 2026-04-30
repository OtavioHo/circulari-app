import 'package:circulari/features/auth/domain/entities/user.dart';
import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';

class GetMeUsecase {
  final AuthRepository _repository;
  const GetMeUsecase(this._repository);

  Future<User> call() => _repository.getMe();
}
