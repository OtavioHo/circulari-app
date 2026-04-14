import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../auth/auth_state_notifier.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/auth_di.dart';
import '../../features/items/items_di.dart';
import '../../features/lists/lists_di.dart';

final sl = GetIt.instance;

void setupInjection() {
  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<Dio>(() => createApiClient(sl()));
  // Starts unauthenticated; main.dart updates it after reading token storage.
  sl.registerSingleton(AuthStateNotifier(false));

  // ── Features ──────────────────────────────────────────────────────────────
  sl.registerAuthFeature();
  sl.registerListsFeature();
  sl.registerItemsFeature();
}
