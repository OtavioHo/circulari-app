import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_source.dart';

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
}
