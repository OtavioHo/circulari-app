import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/auth/data/sources/auth_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';
import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRemoteSource source;

  setUp(() {
    dio = MockDio();
    source = AuthRemoteSource(dio);
  });

  group('login', () {
    test('parses token, refreshToken, and user from a 200 body', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
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
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
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
      when(() => dio.post(any(), data: any(named: 'data')))
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
      when(() => dio.post(any(), data: any(named: 'data')))
          .thenThrow(dioConnectionError());

      expect(
        () => source.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ServerException on malformed body', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
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
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
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
}
