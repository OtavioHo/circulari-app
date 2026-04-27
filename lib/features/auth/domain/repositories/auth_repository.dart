import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> getMe();

  Future<void> logout();
}
