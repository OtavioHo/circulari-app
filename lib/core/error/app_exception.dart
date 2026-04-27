sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please log in again.');
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

final class ServerException extends AppException {
  const ServerException(super.message);
}

final class NetworkException extends AppException {
  const NetworkException() : super('No internet connection.');
}

final class PlanLimitException extends AppException {
  final int? limit;
  const PlanLimitException({this.limit}) : super('You have reached your plan limit.');
}

final class TierRequiredException extends AppException {
  const TierRequiredException() : super('This feature requires a premium plan.');
}
