sealed class RecoveryState {
  const RecoveryState();
}

final class RecoveryInitial extends RecoveryState {
  const RecoveryInitial();
}

final class RecoveryLoading extends RecoveryState {
  const RecoveryLoading();
}

final class RecoveryEmailSent extends RecoveryState {
  const RecoveryEmailSent();
}

final class RecoveryOtpVerified extends RecoveryState {
  final String resetToken;
  const RecoveryOtpVerified({required this.resetToken});
}

final class RecoveryPasswordReset extends RecoveryState {
  const RecoveryPasswordReset();
}

final class RecoveryFailure extends RecoveryState {
  final String message;
  const RecoveryFailure({required this.message});
}
