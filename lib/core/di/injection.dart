import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/network/api_client.dart';
import 'package:circulari/core/storage/token_storage.dart';
import 'package:circulari/features/auth/auth_di.dart';
import 'package:circulari/features/home/home_di.dart';
import 'package:circulari/features/items/items_di.dart';
import 'package:circulari/features/lists/lists_di.dart';
import 'package:circulari/features/profile/profile_di.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  // Starts unauthenticated; main.dart updates it after reading token storage.
  sl.registerSingleton(AuthStateNotifier(false));
  sl.registerLazySingleton<Dio>(() => createApiClient(sl(), sl()));

  // ── Features ──────────────────────────────────────────────────────────────
  sl.registerAuthFeature();
  sl.registerHomeFeature();
  sl.registerListsFeature();
  sl.registerItemsFeature();
  sl.registerProfileFeature();
}
