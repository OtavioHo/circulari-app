sealed class RecoveryEvent {
  const RecoveryEvent();
}

final class RecoveryForgotPasswordRequested extends RecoveryEvent {
  final String email;
  const RecoveryForgotPasswordRequested({required this.email});
}

final class RecoveryVerifyOtpRequested extends RecoveryEvent {
  final String email;
  final String otp;
  const RecoveryVerifyOtpRequested({required this.email, required this.otp});
}

final class RecoveryResetPasswordRequested extends RecoveryEvent {
  final String email;
  final String resetToken;
  final String newPassword;
  const RecoveryResetPasswordRequested({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });
}
