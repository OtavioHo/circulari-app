import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);

Dio createApiClient(TokenStorage tokenStorage) {
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

  dio.interceptors.add(AuthInterceptor(tokenStorage, refreshDio));

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
