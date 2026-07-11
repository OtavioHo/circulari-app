import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/network/auth_interceptor.dart';
import 'package:circulari/core/storage/token_storage.dart';

import '../../helpers/dio_helpers.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockTokenStorage tokenStorage;
  late FakeHttpClientAdapter mainAdapter;
  late FakeHttpClientAdapter refreshAdapter;
  late Dio dio;
  late Dio refreshDio;
  late AuthStateNotifier authNotifier;

  setUp(() {
    tokenStorage = MockTokenStorage();
    mainAdapter = FakeHttpClientAdapter();
    refreshAdapter = FakeHttpClientAdapter();
    authNotifier = AuthStateNotifier(true);
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = mainAdapter;
    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = refreshAdapter;
    dio.interceptors
        .add(AuthInterceptor(tokenStorage, refreshDio, authNotifier));

    // Default storage stubs.
    when(() => tokenStorage.getAccessToken())
        .thenAnswer((_) async => 'old-access');
    when(() => tokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'old-refresh');
    when(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  });

  test('attaches Bearer token on every request', () async {
    mainAdapter.respond(statusCode: 200, body: {'ok': true});

    await dio.get('/anything');

    expect(
      mainAdapter.requests.single.headers['Authorization'],
      'Bearer old-access',
    );
  });

  test('skips Authorization header when no token is stored', () async {
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
    mainAdapter.respond(statusCode: 200, body: {'ok': true});

    await dio.get('/anything');

    expect(mainAdapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('on 401: refreshes, persists new tokens, retries original request',
      () async {
    mainAdapter.respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 200, body: {
      'token': 'new-access',
      'refreshToken': 'new-refresh',
    });
    when(() => tokenStorage.getAccessToken())
        .thenAnswer((_) async => 'old-access');
    refreshAdapter.respond(statusCode: 200, body: {'ok': true});
    // After saveTokens, _retry reads the new access token from storage.
    int readCount = 0;
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async {
      readCount++;
      return readCount == 1 ? 'old-access' : 'new-access';
    });

    final response = await dio.get('/anything');

    expect(response.statusCode, 200);
    expect(response.data['ok'], isTrue);
    verify(() => tokenStorage.saveTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        )).called(1);
    // Retry was sent with the new token.
    expect(
      refreshAdapter.requests.last.headers['Authorization'],
      'Bearer new-access',
    );
  });

  test('on 401 with no refresh token stored: clears tokens and emits Unauthorized',
      () async {
    mainAdapter.respond(statusCode: 401);
    when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>().having(
        (e) => e.error,
        'error',
        isA<UnauthorizedException>(),
      )),
    );
    verify(() => tokenStorage.clearTokens()).called(1);
  });

  test('on malformed refresh body (missing token): clears tokens and fails',
      () async {
    mainAdapter.respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 200, body: {'refreshToken': 'x'});

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>()),
    );
    verify(() => tokenStorage.clearTokens()).called(1);
    verifyNever(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ));
  });

  test('on refresh response with non-string token: fails closed', () async {
    mainAdapter.respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 200, body: {
      'token': 12345, // not a string
      'refreshToken': 'new-refresh',
    });

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>()),
    );
    verify(() => tokenStorage.clearTokens()).called(1);
  });

  test('concurrent 401s only trigger a single refresh call', () async {
    // Three concurrent 401s, one refresh response, three successful retries.
    mainAdapter
      ..respond(statusCode: 401)
      ..respond(statusCode: 401)
      ..respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 200, body: {
      'token': 'new-access',
      'refreshToken': 'new-refresh',
    });
    refreshAdapter
      ..respond(statusCode: 200, body: {'n': 1})
      ..respond(statusCode: 200, body: {'n': 2})
      ..respond(statusCode: 200, body: {'n': 3});

    final results = await Future.wait([
      dio.get('/a'),
      dio.get('/b'),
      dio.get('/c'),
    ]);

    expect(results.map((r) => r.statusCode), everyElement(200));
    // Exactly one refresh request hit /auth/refresh.
    final refreshCalls = refreshAdapter.requests
        .where((r) => r.path == '/auth/refresh')
        .toList();
    expect(refreshCalls, hasLength(1));
    verify(() => tokenStorage.saveTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        )).called(1);
  });

  test('on refresh 5xx: keeps the session (transient failure, not a rejection)',
      () async {
    mainAdapter.respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 500, body: {'message': 'server down'});

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>()),
    );
    // The refresh token is still valid — do not clear it or log out.
    verifyNever(() => tokenStorage.clearTokens());
    expect(authNotifier.isAuthenticated, isTrue);
  });

  test('on refresh 403: clears tokens and logs out (genuine rejection)',
      () async {
    mainAdapter.respond(statusCode: 401);
    refreshAdapter.respond(statusCode: 403, body: {'message': 'Access denied'});

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>()),
    );
    verify(() => tokenStorage.clearTokens()).called(1);
    expect(authNotifier.isAuthenticated, isFalse);
  });

  test('non-401 errors pass through untouched', () async {
    mainAdapter.respond(statusCode: 500, body: {'message': 'boom'});

    await expectLater(
      () => dio.get('/anything'),
      throwsA(isA<DioException>().having(
        (e) => e.response?.statusCode,
        'statusCode',
        500,
      )),
    );
    verifyNever(() => tokenStorage.getRefreshToken());
    verifyNever(() => tokenStorage.clearTokens());
  });
}
