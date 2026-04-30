import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/home/data/sources/home_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late HomeRemoteSource source;

  setUp(() {
    dio = MockDio();
    source = HomeRemoteSource(dio);
  });

  test('parses dashboard summary', () async {
    when(() => dio.get(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/dashboard'),
          statusCode: 200,
          data: {
            'list_count': 3,
            'item_count': 42,
            'total_value': 100.5,
          },
        ));

    final summary = await source.getDashboard();

    expect(summary.listCount, 3);
    expect(summary.itemCount, 42);
    expect(summary.totalValue, 100.5);
  });

  test('defaults total_value to 0 when missing', () async {
    when(() => dio.get(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/dashboard'),
          statusCode: 200,
          data: {'list_count': 0, 'item_count': 0},
        ));

    final summary = await source.getDashboard();

    expect(summary.totalValue, 0.0);
  });

  test('maps DioException to AppException', () async {
    when(() => dio.get(any())).thenThrow(dioException(statusCode: 500));

    expect(() => source.getDashboard(), throwsA(isA<ServerException>()));
  });
}
