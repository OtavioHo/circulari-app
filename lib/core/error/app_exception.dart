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

/// Plan-limit family — any of these means "surface the paywall". Catching the
/// supertype keeps the paywall wiring in one clause per call site.
sealed class QuotaException extends AppException {
  const QuotaException(super.message);
}

final class PlanLimitException extends QuotaException {
  final int? limit;
  const PlanLimitException({this.limit}) : super('You have reached your plan limit.');
}

final class TierRequiredException extends QuotaException {
  const TierRequiredException() : super('This feature requires a premium plan.');
}

/// Copy for an AI analysis hitting the per-user throttle (HTTP 429). Shared by
/// every AI cubit so the wording can't drift between entry points.
const kAiRateLimitMessage = 'Muitas análises seguidas. Aguarde um instante.';

/// The server throttled the request (HTTP 429) — retry after a short wait.
final class RateLimitException extends AppException {
  const RateLimitException() : super('Muitas solicitações. Aguarde um instante.');
}

/// The user dismissed the native purchase sheet — not a real error, so callers
/// should silently return to the paywall.
final class PurchaseCancelledException extends AppException {
  const PurchaseCancelledException() : super('Compra cancelada.');
}

/// A purchase or restore failed (store error, network, etc.).
final class PurchaseException extends AppException {
  const PurchaseException(super.message);
}
