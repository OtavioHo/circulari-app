import 'package:get_it/get_it.dart';

import 'package:circulari/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:circulari/features/profile/data/sources/profile_remote_source.dart';
import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';
import 'package:circulari/features/profile/domain/usecases/get_plan_usecase.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_bloc.dart';

extension ProfileDI on GetIt {
  void registerProfileFeature() {
    registerLazySingleton<ProfileRemoteSource>(() => ProfileRemoteSource(call()));
    registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(call()));
    registerLazySingleton(() => GetPlanUsecase(call()));
    registerFactory(() => PlanBloc(call()));
  }
}
