import 'package:circulari/features/auth/domain/entities/user.dart';

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

  Future<void> forgotPassword({required String email});

  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  });

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
