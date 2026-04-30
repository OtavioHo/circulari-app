import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/profile/data/sources/profile_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ProfileRemoteSource source;

  setUp(() {
    dio = MockDio();
    source = ProfileRemoteSource(dio);
  });

  test('parses plan with bounded and unlimited usages', () async {
    when(() => dio.get(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/plan'),
          statusCode: 200,
          data: {
            'plan': 'premium',
            'lists': {'used': 1, 'max': null},
            'items': {'used': 50, 'max': 100},
            'aiCalls': {'used': 0, 'max': 10},
          },
        ));

    final plan = await source.getPlan();

    expect(plan.plan, 'premium');
    expect(plan.isPremium, isTrue);
    expect(plan.lists.isUnlimited, isTrue);
    expect(plan.items.fraction, 0.5);
  });

  test('maps connection errors to NetworkException', () async {
    when(() => dio.get(any())).thenThrow(dioConnectionError());

    expect(() => source.getPlan(), throwsA(isA<NetworkException>()));
  });

  test('maps 401 to UnauthorizedException', () async {
    when(() => dio.get(any())).thenThrow(dioException(statusCode: 401));

    expect(() => source.getPlan(), throwsA(isA<UnauthorizedException>()));
  });
}
