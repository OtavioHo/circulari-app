import 'package:get_it/get_it.dart';

import 'package:circulari/features/home/data/repositories/home_repository_impl.dart';
import 'package:circulari/features/home/data/sources/home_remote_source.dart';
import 'package:circulari/features/home/domain/repositories/home_repository.dart';
import 'package:circulari/features/home/domain/usecases/get_dashboard_usecase.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_bloc.dart';

extension HomeDI on GetIt {
  void registerHomeFeature() {
    registerLazySingleton<HomeRemoteSource>(() => HomeRemoteSource(call()));
    registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(call()));
    registerLazySingleton(() => GetDashboardUsecase(call()));
    registerFactory(() => DashboardBloc(call()));
  }
}
