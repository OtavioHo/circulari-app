import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/storage/token_storage.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late TokenStorage tokenStorage;

  setUp(() {
    storage = MockSecureStorage();
    tokenStorage = TokenStorage(storage);

    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  });

  group('access token', () {
    test('reads from secure storage on first call', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'persisted');

      final token = await tokenStorage.getAccessToken();

      expect(token, 'persisted');
      verify(() => storage.read(key: 'access_token')).called(1);
    });

    test('caches in memory after first read (no second secure-storage call)',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'persisted');

      await tokenStorage.getAccessToken();
      await tokenStorage.getAccessToken();

      verify(() => storage.read(key: 'access_token')).called(1);
    });

    test('falls back to memory cache if secure-storage read throws',
        () async {
      // First populate memory via saveTokens.
      await tokenStorage.saveTokens(
        accessToken: 'in-memory',
        refreshToken: 'in-memory-refresh',
      );

      // Now, even if storage is broken, in-memory wins.
      when(() => storage.read(key: any(named: 'key')))
          .thenThrow(Exception('boom'));

      final token = await tokenStorage.getAccessToken();
      expect(token, 'in-memory');
    });

    test('saveTokens writes both keys atomically', () async {
      await tokenStorage.saveTokens(
        accessToken: 'a',
        refreshToken: 'r',
      );

      verify(() => storage.write(key: 'access_token', value: 'a')).called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'r')).called(1);
    });

    test('saveTokens swallows storage failures and still updates memory',
        () async {
      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenThrow(Exception('boom'));

      await tokenStorage.saveTokens(accessToken: 'a', refreshToken: 'r');

      // Memory was still updated even though disk write failed.
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      expect(await tokenStorage.getAccessToken(), 'a');
    });

    test('clearTokens nulls memory and deletes both keys', () async {
      await tokenStorage.saveTokens(accessToken: 'a', refreshToken: 'r');

      await tokenStorage.clearTokens();

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);

      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      expect(await tokenStorage.getAccessToken(), isNull);
    });
  });

  group('user name', () {
    test('round-trips via secure storage and memory cache', () async {
      await tokenStorage.saveUserName('Jane');

      verify(() => storage.write(key: 'user_name', value: 'Jane')).called(1);

      // No need to hit storage on subsequent reads.
      expect(await tokenStorage.getUserName(), 'Jane');
      verifyNever(() => storage.read(key: 'user_name'));
    });

    test('clearUserName resets cache and deletes from storage', () async {
      await tokenStorage.saveUserName('Jane');
      await tokenStorage.clearUserName();

      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      expect(await tokenStorage.getUserName(), isNull);
      verify(() => storage.delete(key: 'user_name')).called(1);
    });
  });
}
