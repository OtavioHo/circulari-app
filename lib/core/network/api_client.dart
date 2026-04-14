import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

Dio createApiClient(TokenStorage tokenStorage) {
  // Separate plain Dio used only for token refresh — no interceptors to avoid loops.
  final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStorage, refreshDio));

  return dio;
}
