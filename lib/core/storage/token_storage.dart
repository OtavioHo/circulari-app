import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] with an in-memory fallback.
///
/// On Flutter Web the underlying Web Crypto API can throw `OperationError`
/// (a DOMException) that escapes Dart's try/catch. Keeping the last-known
/// tokens in memory guarantees that the auth interceptor always has a token
/// for the current session, even when the encrypted store misbehaves.
class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  // In-memory fallback — cleared on cold start, survives hot reload.
  String? _accessToken;
  String? _refreshToken;

  TokenStorage(this._storage);

  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    try {
      _accessToken = await _storage.read(key: _accessKey);
    } catch (e) {
      debugPrint('TokenStorage: failed to read access token — $e');
    }
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) return _refreshToken;
    try {
      _refreshToken = await _storage.read(key: _refreshKey);
    } catch (e) {
      debugPrint('TokenStorage: failed to read refresh token — $e');
    }
    return _refreshToken;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    try {
      await Future.wait([
        _storage.write(key: _accessKey, value: accessToken),
        _storage.write(key: _refreshKey, value: refreshToken),
      ]);
    } catch (e) {
      debugPrint('TokenStorage: failed to persist tokens — $e');
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      await Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
      ]);
    } catch (e) {
      debugPrint('TokenStorage: failed to clear tokens — $e');
    }
  }
}
