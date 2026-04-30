import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:circulari/features/auth/presentation/bloc/recovery_event.dart';
import 'package:circulari/features/auth/presentation/bloc/recovery_state.dart';

class RecoveryBloc extends Bloc<RecoveryEvent, RecoveryState> {
  final ForgotPasswordUsecase _forgotPassword;
  final VerifyResetOtpUsecase _verifyOtp;
  final ResetPasswordUsecase _resetPassword;

  RecoveryBloc({
    required ForgotPasswordUsecase forgotPassword,
    required VerifyResetOtpUsecase verifyOtp,
    required ResetPasswordUsecase resetPassword,
  })  : _forgotPassword = forgotPassword,
        _verifyOtp = verifyOtp,
        _resetPassword = resetPassword,
        super(const RecoveryInitial()) {
    on<RecoveryForgotPasswordRequested>(_onForgotPassword);
    on<RecoveryVerifyOtpRequested>(_onVerifyOtp);
    on<RecoveryResetPasswordRequested>(_onResetPassword);
  }

  Future<void> _onForgotPassword(
    RecoveryForgotPasswordRequested event,
    Emitter<RecoveryState> emit,
  ) async {
    emit(const RecoveryLoading());
    try {
      await _forgotPassword(email: event.email);
      emit(const RecoveryEmailSent());
    } on AppException catch (e) {
      emit(RecoveryFailure(message: e.message));
    }
  }

  Future<void> _onVerifyOtp(
    RecoveryVerifyOtpRequested event,
    Emitter<RecoveryState> emit,
  ) async {
    emit(const RecoveryLoading());
    try {
      final token = await _verifyOtp(email: event.email, otp: event.otp);
      emit(RecoveryOtpVerified(resetToken: token));
    } on AppException catch (e) {
      emit(RecoveryFailure(message: e.message));
    }
  }

  Future<void> _onResetPassword(
    RecoveryResetPasswordRequested event,
    Emitter<RecoveryState> emit,
  ) async {
    emit(const RecoveryLoading());
    try {
      await _resetPassword(
        email: event.email,
        resetToken: event.resetToken,
        newPassword: event.newPassword,
      );
      emit(const RecoveryPasswordReset());
    } on AppException catch (e) {
      emit(RecoveryFailure(message: e.message));
    }
  }
}
