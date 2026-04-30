import 'package:bloc_test/bloc_test.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_event.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_state.dart';
import 'package:circulari/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

Widget _wrap(AuthBloc bloc) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, _) => const SizedBox(),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    theme: circulariLightThemeData,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AuthLoginRequested(email: '', password: ''),
    );
  });

  late MockAuthBloc bloc;

  setUp(() => bloc = MockAuthBloc());

  testWidgets('shows form fields when state is AuthInitial', (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());

    await tester.pumpWidget(_wrap(bloc));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('shows progress indicator when state is AuthLoading',
      (tester) async {
    when(() => bloc.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(_wrap(bloc));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders form again on AuthFailure', (tester) async {
    when(() => bloc.state).thenReturn(const AuthFailure('Bad creds'));

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('shows snackbar with error message when state changes to Failure',
      (tester) async {
    whenListen(
      bloc,
      Stream.fromIterable(<AuthState>[const AuthFailure('Bad creds')]),
      initialState: const AuthInitial(),
    );

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.text('Bad creds'), findsOneWidget);
  });

  testWidgets('blocks submit and shows validation errors on empty form',
      (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());

    await tester.pumpWidget(_wrap(bloc));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Required'), findsWidgets);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('rejects invalid email formats', (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());

    await tester.pumpWidget(_wrap(bloc));
    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, '12345678');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('rejects passwords shorter than 8 characters', (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());

    await tester.pumpWidget(_wrap(bloc));
    await tester
        .enterText(find.byType(TextFormField).first, 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'short');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('At least 8 characters'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('dispatches AuthLoginRequested with trimmed email on submit',
      (tester) async {
    when(() => bloc.state).thenReturn(const AuthInitial());

    await tester.pumpWidget(_wrap(bloc));
    await tester
        .enterText(find.byType(TextFormField).first, '  jane@example.com  ');
    await tester.enterText(find.byType(TextFormField).last, 'hunter2222');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured.single;
    expect(captured, isA<AuthLoginRequested>());
    final event = captured as AuthLoginRequested;
    expect(event.email, 'jane@example.com');
    expect(event.password, 'hunter2222');
  });
}
