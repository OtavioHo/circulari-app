import 'package:get_it/get_it.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:circulari/features/auth/data/sources/auth_remote_source.dart';
import 'package:circulari/features/auth/domain/repositories/auth_repository.dart';
import 'package:circulari/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/login_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/logout_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/register_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:circulari/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:circulari/features/auth/presentation/bloc/recovery_bloc.dart';

extension AuthDI on GetIt {
  void registerAuthFeature() {
    registerLazySingleton<AuthRemoteSource>(() => AuthRemoteSource(call()));
    registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(call(), call()),
    );
    registerLazySingleton(() => GetMeUsecase(call()));
    registerLazySingleton(() => LoginUsecase(call()));
    registerLazySingleton(() => RegisterUsecase(call()));
    registerLazySingleton(() => LogoutUsecase(call()));
    registerFactory(
      () => AuthBloc(
        login: call(),
        register: call(),
        logout: call(),
        authStateNotifier: call<AuthStateNotifier>(),
      ),
    );
    registerLazySingleton(() => ForgotPasswordUsecase(call()));
    registerLazySingleton(() => VerifyResetOtpUsecase(call()));
    registerLazySingleton(() => ResetPasswordUsecase(call()));
    registerFactory(
      () => RecoveryBloc(
        forgotPassword: call(),
        verifyOtp: call(),
        resetPassword: call(),
      ),
    );
  }
}
