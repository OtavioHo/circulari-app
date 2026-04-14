import 'dart:async';

import 'package:dio/dio.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';

/// Injects the JWT on every request and transparently refreshes it on 401.
/// Uses a separate [refreshDio] instance to avoid infinite interceptor loops.
///
/// Concurrent 401 responses are serialised: only the first failure triggers a
/// refresh call; subsequent failures wait for that refresh to complete and then
/// retry with the new token, preventing the refresh token from being consumed
/// multiple times in parallel.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;

  /// Non-null while a refresh is in flight. All other 401 handlers wait on it.
  Completer<void>? _refreshCompleter;

  AuthInterceptor(this._tokenStorage, this._refreshDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // A refresh is already in flight — wait for it, then retry with the new token.
    if (_refreshCompleter != null) {
      try {
        await _refreshCompleter!.future;
        return handler.resolve(await _retry(err.requestOptions));
      } catch (_) {
        return handler.reject(_unauthorizedError(err.requestOptions));
      }
    }

    _refreshCompleter = Completer<void>();
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('no_refresh_token');
      }

      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccess = response.data['token'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      final completer = _refreshCompleter!;
      _refreshCompleter = null;
      completer.complete();

      return handler.resolve(await _retry(err.requestOptions));
    } catch (e) {
      final completer = _refreshCompleter!;
      _refreshCompleter = null;
      completer.completeError(e);
      completer.future.ignore(); // prevent unhandled-exception when no concurrent waiter
      await _tokenStorage.clearTokens();
      return handler.reject(_unauthorizedError(err.requestOptions));
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return _refreshDio.fetch(options);
  }

  DioException _unauthorizedError(RequestOptions options) => DioException(
        requestOptions: options,
        error: const UnauthorizedException(),
      );
}
