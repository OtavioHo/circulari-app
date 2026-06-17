import 'package:get_it/get_it.dart';

import 'package:circulari/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:circulari/features/subscription/data/sources/subscription_remote_source.dart';
import 'package:circulari/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:circulari/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:circulari/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:circulari/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_bloc.dart';

extension SubscriptionDI on GetIt {
  void registerSubscriptionFeature() {
    registerLazySingleton<SubscriptionRemoteSource>(() => SubscriptionRemoteSource(call()));
    registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(call()));
    registerLazySingleton(() => GetOfferingsUsecase(call()));
    registerLazySingleton(() => PurchasePackageUsecase(call()));
    registerLazySingleton(() => RestorePurchasesUsecase(call()));
    registerFactory(
      () => PaywallBloc(
        getOfferings: call(),
        purchase: call(),
        restore: call(),
        reconcilePlan: call(),
      ),
    );
  }
}
