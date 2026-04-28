import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/storage/token_storage.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/data/sources/auth_remote_source.dart';

import '../../../../helpers/fixtures.dart';

class MockAuthRemoteSource extends Mock implements AuthRemoteSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteSource source;
  late MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    source = MockAuthRemoteSource();
    tokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(source, tokenStorage);

    when(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.saveUserName(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
    when(() => tokenStorage.clearUserName()).thenAnswer((_) async {});
  });

  group('login', () {
    test('persists tokens and user name, then returns the user', () async {
      when(() => source.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => (
            token: tAccessToken,
            refreshToken: tRefreshToken,
            user: tUserModel,
          ));

      final user = await repository.login(
        email: 'jane@example.com',
        password: 'hunter2222',
      );

      expect(user, tUserModel);
      verify(() => tokenStorage.saveTokens(
            accessToken: tAccessToken,
            refreshToken: tRefreshToken,
          )).called(1);
      verify(() => tokenStorage.saveUserName(tUserModel.name)).called(1);
    });

    test('does not persist tokens if the source throws', () async {
      when(() => source.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('boom'));

      expect(
        () => repository.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => tokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
    });
  });

  group('logout', () {
    test('clears tokens and user name even when remote logout fails',
        () async {
      when(() => source.logout()).thenThrow(Exception('network'));

      expect(repository.logout(), throwsA(isA<Exception>()));
      // Wait for async finally block.
      await Future<void>.delayed(Duration.zero);

      verify(() => tokenStorage.clearTokens()).called(1);
      verify(() => tokenStorage.clearUserName()).called(1);
    });

    test('clears tokens on successful remote logout', () async {
      when(() => source.logout()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokenStorage.clearTokens()).called(1);
      verify(() => tokenStorage.clearUserName()).called(1);
    });
  });
}
