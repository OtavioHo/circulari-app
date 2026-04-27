import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/user_model.dart';

class AuthRemoteSource {
  final Dio _dio;
  const AuthRemoteSource(this._dio);

  Future<({String token, String refreshToken, UserModel user})> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      final data = _parseBody(response.data);
      return (
        token: _requireString(data, 'token'),
        refreshToken: _requireString(data, 'refreshToken'),
        user: UserModel.fromJson(_requireMap(data, 'user')),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<({String token, String refreshToken, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = _parseBody(response.data);
      return (
        token: _requireString(data, 'token'),
        refreshToken: _requireString(data, 'refreshToken'),
        user: UserModel.fromJson(_requireMap(data, 'user')),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Map<String, dynamic> _parseBody(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response format.');
    }
    return data;
  }

  String _requireString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String) throw ServerException('Missing field: $key');
    return value;
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! Map<String, dynamic>) throw ServerException('Missing field: $key');
    return value;
  }

  /// On auth endpoints a 401 means wrong credentials, not an expired session.
  /// Remap [UnauthorizedException] → [ServerException] so the UI shows the
  /// server's message ("Invalid email or password") rather than "Session expired".
  AppException _mapError(DioException e) {
    final mapped = mapDioError(e);
    if (mapped is UnauthorizedException) {
      final message =
          e.response?.data?['message'] as String? ?? 'Invalid credentials.';
      return ServerException(message);
    }
    return mapped;
  }
}
