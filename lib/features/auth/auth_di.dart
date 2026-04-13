import 'package:get_it/get_it.dart';

import '../../core/auth/auth_state_notifier.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/sources/auth_remote_source.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

extension AuthDI on GetIt {
  void registerAuthFeature() {
    registerLazySingleton<AuthRemoteSource>(() => AuthRemoteSource(call()));
    registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(call(), call()),
    );
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
  }
}
