import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/auth/auth_state_notifier.dart';
import 'package:app/core/error/app_exception.dart';
import 'package:app/features/auth/domain/usecases/login_usecase.dart';
import 'package:app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app/features/auth/domain/usecases/register_usecase.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_event.dart';
import 'package:app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/fixtures.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockLoginUsecase login;
  late MockRegisterUsecase register;
  late MockLogoutUsecase logout;
  late AuthStateNotifier notifier;

  setUp(() {
    login = MockLoginUsecase();
    register = MockRegisterUsecase();
    logout = MockLogoutUsecase();
    notifier = AuthStateNotifier(false);
  });

  AuthBloc buildBloc() => AuthBloc(
        login: login,
        register: register,
        logout: logout,
        authStateNotifier: notifier,
      );

  test('initial state is AuthInitial', () {
    expect(buildBloc().state, isA<AuthInitial>());
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] and updates notifier on success',
      build: buildBloc,
      setUp: () => when(() => login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUser),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'jane@example.com',
        password: 'hunter2222',
      )),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
      verify: (_) {
        expect(notifier.isAuthenticated, isTrue);
        expect(notifier.userName, tUser.name);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Failure] and leaves notifier untouched on failure',
      build: buildBloc,
      setUp: () => when(() => login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ServerException('Invalid email or password')),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'a@b.com',
        password: '12345678',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.message,
          'message',
          'Invalid email or password',
        ),
      ],
      verify: (_) {
        expect(notifier.isAuthenticated, isFalse);
        expect(notifier.userName, isNull);
      },
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Success] and clears notifier',
      build: buildBloc,
      setUp: () {
        notifier
          ..setAuthenticated(true)
          ..setUserName('Jane');
        when(() => logout()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
      verify: (_) {
        expect(notifier.isAuthenticated, isFalse);
        expect(notifier.userName, isNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits Failure when logout throws',
      build: buildBloc,
      setUp: () =>
          when(() => logout()).thenThrow(const NetworkException()),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );
  });
}
