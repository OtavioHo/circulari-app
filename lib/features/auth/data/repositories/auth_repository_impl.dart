import 'package:circulari/core/storage/token_storage.dart';
import 'package:circulari/features/auth/domain/entities/user.dart';
import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/data/sources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _source;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl(this._source, this._tokenStorage);

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _source.register(
      email: email,
      password: password,
      name: name,
    );
    await Future.wait([
      _tokenStorage.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      ),
      _tokenStorage.saveUserName(result.user.name),
    ]);
    return result.user;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final result = await _source.login(email: email, password: password);
    await Future.wait([
      _tokenStorage.saveTokens(
        accessToken: result.token,
        refreshToken: result.refreshToken,
      ),
      _tokenStorage.saveUserName(result.user.name),
    ]);
    return result.user;
  }

  @override
  Future<User> getMe() => _source.getMe();

  @override
  Future<void> logout() async {
    try {
      await _source.logout();
    } finally {
      await Future.wait([
        _tokenStorage.clearTokens(),
        _tokenStorage.clearUserName(),
      ]);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) =>
      _source.forgotPassword(email: email);

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) =>
      _source.verifyResetOtp(email: email, otp: otp);

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) =>
      _source.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
}
