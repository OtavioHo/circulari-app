import 'package:dio/dio.dart';
import 'package:circulari/core/error/app_exception.dart';

/// Maps a [DioException] to an [AppException].
///
/// A 401 on an authenticated endpoint means the session expired →
/// [UnauthorizedException]. For auth endpoints (login / register) where 401
/// means "wrong credentials", callers should remap the result themselves.
AppException mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return const NetworkException();
  }
  final status = e.response?.statusCode;
  final message = _extractMessage(e.response?.data);
  if (status == 401) return const UnauthorizedException();
  if (status == 403) {
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    if (code == 'LIMIT_REACHED') {
      final limit = data is Map ? data['limit'] as int? : null;
      return PlanLimitException(limit: limit);
    }
    return const TierRequiredException();
  }
  if (status == 404) return NotFoundException(message);
  return ServerException(message);
}

/// Extracts a human-readable error message from the response body.
///
/// NestJS class-validator returns `message` as an array of strings on
/// validation failures and as a plain string on thrown exceptions. We accept
/// both so a List doesn't crash the `as String?` cast.
String _extractMessage(dynamic data) {
  if (data is! Map) return 'An unexpected error occurred.';
  final raw = data['message'];
  if (raw is String) return raw;
  if (raw is List) {
    final lines = raw.whereType<String>().toList();
    if (lines.isNotEmpty) return lines.join('\n');
  }
  return 'An unexpected error occurred.';
}
