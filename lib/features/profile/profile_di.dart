import 'package:get_it/get_it.dart';

import 'data/repositories/profile_repository_impl.dart';
import 'data/sources/profile_remote_source.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/get_plan_usecase.dart';
import 'presentation/bloc/plan_bloc.dart';

extension ProfileDI on GetIt {
  void registerProfileFeature() {
    registerLazySingleton<ProfileRemoteSource>(() => ProfileRemoteSource(call()));
    registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(call()));
    registerLazySingleton(() => GetPlanUsecase(call()));
    registerFactory(() => PlanBloc(call()));
  }
}
