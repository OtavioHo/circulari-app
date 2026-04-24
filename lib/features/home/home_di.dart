import 'package:get_it/get_it.dart';

import 'data/repositories/home_repository_impl.dart';
import 'data/sources/home_remote_source.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_dashboard_usecase.dart';
import 'presentation/bloc/dashboard_bloc.dart';

extension HomeDI on GetIt {
  void registerHomeFeature() {
    registerLazySingleton<HomeRemoteSource>(() => HomeRemoteSource(call()));
    registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(call()));
    registerLazySingleton(() => GetDashboardUsecase(call()));
    registerFactory(() => DashboardBloc(call()));
  }
}
