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
  final message =
      e.response?.data?['message'] as String? ?? 'An unexpected error occurred.';
  if (status == 401) return const UnauthorizedException();
  if (status == 403) {
    final code = e.response?.data?['code'] as String?;
    if (code == 'LIMIT_REACHED') {
      final limit = e.response?.data?['limit'] as int?;
      return PlanLimitException(limit: limit);
    }
    return const TierRequiredException();
  }
  if (status == 404) return NotFoundException(message);
  return ServerException(message);
}
