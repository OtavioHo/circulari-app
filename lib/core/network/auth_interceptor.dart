import 'dart:async';

import 'package:dio/dio.dart';
import '../auth/auth_state_notifier.dart';
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
  final AuthStateNotifier _authStateNotifier;

  /// Non-null while a refresh is in flight. All other 401 handlers wait on it.
  Completer<void>? _refreshCompleter;

  AuthInterceptor(
    this._tokenStorage,
    this._refreshDio,
    this._authStateNotifier,
  );

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

    // Claim the refresh slot atomically. In single-threaded Dart this assignment
    // happens-before any further `await`, so concurrent 401s either see a
    // non-null completer (and wait) or claim it themselves once it is cleared.
    final existing = _refreshCompleter;
    if (existing != null) {
      try {
        await existing.future;
        return handler.resolve(await _retry(err.requestOptions));
      } catch (_) {
        return handler.reject(_unauthorizedError(err.requestOptions));
      }
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;
    // Pre-attach a no-op listener so an error never surfaces as "unhandled"
    // when no concurrent waiter happens to be attached.
    completer.future.ignore();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw const UnauthorizedException();
      }

      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data is! Map) {
        throw const UnauthorizedException();
      }
      final newAccess = data['token'];
      final newRefresh = data['refreshToken'];
      if (newAccess is! String || newAccess.isEmpty ||
          newRefresh is! String || newRefresh.isEmpty) {
        throw const UnauthorizedException();
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      _refreshCompleter = null;
      completer.complete();

      return handler.resolve(await _retry(err.requestOptions));
    } catch (e) {
      _refreshCompleter = null;
      completer.completeError(e);
      await _tokenStorage.clearTokens();
      _authStateNotifier.setAuthenticated(false);
      _authStateNotifier.setUserName(null);
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
