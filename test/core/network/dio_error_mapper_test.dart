import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/core/network/dio_error_mapper.dart';

import '../../helpers/dio_helpers.dart';

void main() {
  group('mapDioError', () {
    test('connectionTimeout → NetworkException', () {
      expect(
        mapDioError(dioConnectionError(type: DioExceptionType.connectionTimeout)),
        isA<NetworkException>(),
      );
    });

    test('receiveTimeout → NetworkException', () {
      expect(
        mapDioError(dioConnectionError(type: DioExceptionType.receiveTimeout)),
        isA<NetworkException>(),
      );
    });

    test('connectionError → NetworkException', () {
      expect(
        mapDioError(dioConnectionError()),
        isA<NetworkException>(),
      );
    });

    test('401 → UnauthorizedException', () {
      expect(
        mapDioError(dioException(statusCode: 401, body: {})),
        isA<UnauthorizedException>(),
      );
    });

    test('403 + LIMIT_REACHED → PlanLimitException with limit', () {
      final mapped = mapDioError(dioException(
        statusCode: 403,
        body: {'code': 'LIMIT_REACHED', 'limit': 25},
      ));
      expect(mapped, isA<PlanLimitException>());
      expect((mapped as PlanLimitException).limit, 25);
    });

    test('403 without LIMIT_REACHED code → TierRequiredException', () {
      expect(
        mapDioError(dioException(statusCode: 403, body: {})),
        isA<TierRequiredException>(),
      );
    });

    test('404 → NotFoundException with server message', () {
      final mapped = mapDioError(dioException(
        statusCode: 404,
        body: {'message': 'Item not found'},
      ));
      expect(mapped, isA<NotFoundException>());
      expect((mapped as NotFoundException).message, 'Item not found');
    });

    test('500 → ServerException with server message', () {
      final mapped = mapDioError(dioException(
        statusCode: 500,
        body: {'message': 'Internal'},
      ));
      expect(mapped, isA<ServerException>());
      expect((mapped as ServerException).message, 'Internal');
    });

    test('500 without message → ServerException with default message', () {
      final mapped = mapDioError(dioException(statusCode: 500, body: {}));
      expect((mapped as ServerException).message,
          'An unexpected error occurred.');
    });
  });
}
