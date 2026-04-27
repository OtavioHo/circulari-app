import '../repositories/auth_repository.dart';

class VerifyResetOtpUsecase {
  final AuthRepository _repository;
  const VerifyResetOtpUsecase(this._repository);

  Future<String> call({required String email, required String otp}) =>
      _repository.verifyResetOtp(email: email, otp: otp);
}
