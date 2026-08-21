import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/network/auth_interceptor.dart';
import 'package:circulari/features/auth/data/sources/auth_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';
import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRemoteSource source;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = MockDio();
    source = AuthRemoteSource(dio);
  });

  group('login', () {
    test('parses token, refreshToken, and user from a 200 body', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 200,
          data: {
            'token': tAccessToken,
            'refreshToken': tRefreshToken,
            'user': tUserJson,
          },
        ),
      );

      final result = await source.login(
        email: 'jane@example.com',
        password: 'hunter2222',
      );

      expect(result.token, tAccessToken);
      expect(result.refreshToken, tRefreshToken);
      expect(result.user.id, tUser.id);
      expect(result.user.email, tUser.email);
      expect(result.user.name, tUser.name);
    });

    test('remaps 401 from auth endpoint to ServerException with server message',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenThrow(
        dioException(
          statusCode: 401,
          body: {'message': 'Invalid email or password'},
        ),
      );

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Invalid email or password',
        )),
      );
    });

    test('uses default message when 401 body has no message', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(dioException(statusCode: 401, body: {}));

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Invalid credentials.',
        )),
      );
    });

    test('maps connection errors to NetworkException', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(dioConnectionError());

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ServerException on malformed body', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 200,
          data: 'not-a-map',
        ),
      );

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when token field is missing', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 200,
          data: {'refreshToken': tRefreshToken, 'user': tUserJson},
        ),
      );

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          contains('token'),
        )),
      );
    });
  });

  group('logout', () {
    test('posts to /auth/logout and returns', () async {
      when(() => dio.post(any())).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/logout'),
          statusCode: 204,
        ),
      );

      await source.logout();

      verify(() => dio.post('/auth/logout')).called(1);
    });

    test('maps DioException to AppException', () async {
      when(() => dio.post(any())).thenThrow(dioException(statusCode: 500));

      expect(() => source.logout(), throwsA(isA<AppException>()));
    });
  });

  group('skipAuthRefresh marker', () {
    test('every unauthenticated endpoint tells AuthInterceptor to skip the '
        'refresh flow on 401', () async {
      when(() => dio.post(any(),
              data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (invocation) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: invocation.positionalArguments.first as String,
          ),
          statusCode: 200,
          data: {
            'token': tAccessToken,
            'refreshToken': tRefreshToken,
            'user': tUserJson,
            'resetToken': 'reset-token',
          },
        ),
      );

      await source.login(email: 'a@b.com', password: '12345678');
      await source.register(
          email: 'a@b.com', password: '12345678', name: 'Jane');
      await source.forgotPassword(email: 'a@b.com');
      await source.verifyResetOtp(email: 'a@b.com', otp: '123456');
      await source.resetPassword(
        email: 'a@b.com',
        resetToken: 'reset-token',
        newPassword: 'hunter2222',
      );

      final captured = verify(() => dio.post(any(),
              data: any(named: 'data'), options: captureAny(named: 'options')))
          .captured;
      expect(captured, hasLength(5));
      for (final options in captured) {
        expect((options as Options?)?.extra?[kSkipAuthRefresh], isTrue);
      }
    });
  });
}
