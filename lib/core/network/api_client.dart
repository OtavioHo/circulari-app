import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/storage/token_storage.dart';
import 'package:circulari/core/network/auth_interceptor.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://circulari.aragoni.dev/api/v1',
);

Dio createApiClient(
  TokenStorage tokenStorage,
  AuthStateNotifier authStateNotifier,
) {
  _assertSecureBaseUrl(_baseUrl);

  final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
  _applyTransportSecurity(refreshDio);

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  _applyTransportSecurity(dio);

  dio.interceptors.add(
    AuthInterceptor(tokenStorage, refreshDio, authStateNotifier),
  );

  return dio;
}

void _assertSecureBaseUrl(String url) {
  if (kReleaseMode && !url.startsWith('https://')) {
    throw StateError(
      'Refusing to start: API_BASE_URL must use HTTPS in release builds.',
    );
  }
}

/// Fail-closed TLS configuration. Real certificate pinning requires comparing
/// the server's leaf certificate SHA-256 against a known fingerprint; that
/// needs `package:crypto` plus the production cert(s). Until those are wired
/// up, we at least guarantee that invalid certificates are never accepted.
void _applyTransportSecurity(Dio dio) {
  if (kIsWeb) return; // Browser handles TLS.

  final adapter = dio.httpClientAdapter;
  if (adapter is! IOHttpClientAdapter) return;

  adapter.createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => false;
    return client;
  };
}
