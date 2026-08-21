import 'dart:async';

import 'package:dio/dio.dart';
import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/storage/token_storage.dart';

/// [RequestOptions.extra] key marking a request whose 401 must bypass the
/// token-refresh flow. Set it via `Options(extra: {kSkipAuthRefresh: true})`
/// on unauthenticated auth endpoints (login, register, password reset...)
/// where a 401 means wrong credentials — not an expired session — so the
/// remote source can surface the server's message untouched.
const String kSkipAuthRefresh = 'skipAuthRefresh';

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
    // Dio does not await this async callback: an escaping throw (e.g. a Web
    // Crypto DOMException from TokenStorage on Flutter Web) would leave the
    // handler unresolved and hang the caller's Future forever. Every path
    // must end in exactly one of next/reject.
    final String? token;
    try {
      token = await _tokenStorage.getAccessToken();
    } catch (e, stackTrace) {
      return handler.reject(DioException(
        requestOptions: options,
        error: e,
        stackTrace: stackTrace,
      ));
    }
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
    // Call sites mark unauthenticated auth endpoints (login, register,
    // password reset...) with [kSkipAuthRefresh]: their 401s mean wrong
    // credentials, not an expired session, and must pass through untouched.
    // `/auth/me` and `/auth/logout` are session-bound and stay in the refresh
    // flow; `/auth/refresh` never reaches this interceptor (separate Dio).
    if (err.requestOptions.extra[kSkipAuthRefresh] == true) {
      return handler.next(err);
    }

    // Claim the refresh slot atomically. In single-threaded Dart this assignment
    // happens-before any further `await`, so concurrent 401s either see a
    // non-null completer (and wait) or claim it themselves once it is cleared.
    final existing = _refreshCompleter;
    if (existing != null) {
      try {
        await existing.future;
      } catch (_) {
        return handler.reject(_unauthorizedError(err.requestOptions));
      }
      // The refresh succeeded — a failure of the retried request is its own
      // error and must propagate as such, not as "unauthorized".
      return _retryAndForward(err.requestOptions, handler);
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
    } catch (e) {
      _refreshCompleter = null;
      completer.completeError(e);
      // Only end the session when the refresh token was genuinely rejected
      // (401/403). Transient failures — network blip, timeout, DNS, server 5xx —
      // leave a still-valid refresh token intact, so we surface the error but
      // keep the user logged in; the next request retries the refresh.
      if (_isAuthRejection(e)) {
        try {
          await _tokenStorage.clearTokens();
        } catch (_) {
          // Best-effort teardown: a storage failure here must not leave the
          // handler unresolved — we still reject below either way.
        }
        _authStateNotifier.setAuthenticated(false);
        _authStateNotifier.setUserName(null);
        _authStateNotifier.setUserEmail(null);
      }
      return handler.reject(_unauthorizedError(err.requestOptions));
    }

    // The retry runs outside the try/catch above: the completer has already
    // completed exactly once, and a retry failure is its own error — it must
    // not complete the completer again nor masquerade as a refresh rejection.
    return _retryAndForward(err.requestOptions, handler);
  }

  /// Retries [options] with the freshly-saved token and forwards the outcome:
  /// success resolves the original request, failure propagates the retry's own
  /// [DioException] (never remapped to [UnauthorizedException]).
  Future<void> _retryAndForward(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      handler.resolve(await _retry(options));
    } on DioException catch (e) {
      handler.reject(e);
    } catch (e, stackTrace) {
      // Dio does not await this async callback, so a non-Dio throw escaping
      // [_retry] (e.g. a Web Crypto DOMException from TokenStorage on Flutter
      // Web) would leave the handler unresolved and hang the caller's Future
      // forever. Wrap it so the error always reaches the caller.
      handler.reject(DioException(
        requestOptions: options,
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return _refreshDio.fetch(options);
  }

  /// True when the refresh failed because the token itself is invalid — a 401/403
  /// from `/auth/refresh`, or a locally-detected missing/malformed refresh token.
  /// Transport-level failures (connection/timeout) and 5xx are NOT rejections.
  bool _isAuthRejection(Object error) {
    if (error is UnauthorizedException) return true;
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == 401 || status == 403;
    }
    return false;
  }

  DioException _unauthorizedError(RequestOptions options) => DioException(
        requestOptions: options,
        error: const UnauthorizedException(),
      );
}
