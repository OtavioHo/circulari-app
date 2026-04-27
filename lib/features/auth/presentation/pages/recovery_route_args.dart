sealed class RecoveryRouteArgs {
  const RecoveryRouteArgs();
}

final class VerifyOtpArgs extends RecoveryRouteArgs {
  final String email;
  const VerifyOtpArgs({required this.email});
}

final class ResetPasswordArgs extends RecoveryRouteArgs {
  final String email;
  final String resetToken;
  const ResetPasswordArgs({required this.email, required this.resetToken});
}
