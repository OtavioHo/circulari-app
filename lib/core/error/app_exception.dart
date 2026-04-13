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
