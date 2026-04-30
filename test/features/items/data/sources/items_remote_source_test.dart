import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/data/sources/items_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ItemsRemoteSource source;

  setUp(() {
    dio = MockDio();
    source = ItemsRemoteSource(dio);
    registerFallbackValue(<String, dynamic>{});
  });

  Map<String, dynamic> okItemJson({String id = 'i1'}) => {
        'id': id,
        'list_id': 'list-1',
        'name': 'Item',
        'quantity': 1,
        'images': [],
        'created_at': '2024-01-01T00:00:00.000Z',
      };

  group('getCategories', () {
    test('parses a list of categories', () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/categories'),
            statusCode: 200,
            data: [
              {'id': 'c1', 'name': 'Books'},
              {'id': 'c2', 'name': 'Tools'},
            ],
          ));

      final categories = await source.getCategories();

      expect(categories, hasLength(2));
      expect(categories.first.id, 'c1');
      expect(categories.first.name, 'Books');
    });

    test('throws ServerException when payload is not a list', () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/categories'),
            statusCode: 200,
            data: {'unexpected': true},
          ));

      expect(() => source.getCategories(), throwsA(isA<ServerException>()));
    });
  });

  group('getItems', () {
    test('parses items from {data: [...]} envelope', () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/lists/list-1/items'),
            statusCode: 200,
            data: {
              'data': [okItemJson()]
            },
          ));

      final items = await source.getItems('list-1');

      expect(items, hasLength(1));
      expect(items.first.id, 'i1');
    });

    test('throws ServerException when envelope is missing data array',
        () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 200,
            data: {'data': 'not-a-list'},
          ));

      expect(() => source.getItems('list-1'), throwsA(isA<ServerException>()));
    });

    test('maps DioException → AppException', () async {
      when(() => dio.get(any()))
          .thenThrow(dioException(statusCode: 500, body: {}));

      expect(() => source.getItems('list-1'), throwsA(isA<ServerException>()));
    });
  });

  group('createItem', () {
    test('maps 403 LIMIT_REACHED to PlanLimitException', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioException(
          statusCode: 403,
          body: {'code': 'LIMIT_REACHED', 'limit': 100},
        ),
      );

      await expectLater(
        () => source.createItem(listId: 'list-1', name: 'X'),
        throwsA(isA<PlanLimitException>().having(
          (e) => e.limit,
          'limit',
          100,
        )),
      );
    });

    test('maps 403 without LIMIT_REACHED code to TierRequiredException',
        () async {
      when(() => dio.post(any(), data: any(named: 'data')))
          .thenThrow(dioException(statusCode: 403, body: {}));

      await expectLater(
        () => source.createItem(listId: 'list-1', name: 'X'),
        throwsA(isA<TierRequiredException>()),
      );
    });

    test('parses created item from response', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/items'),
          statusCode: 201,
          data: okItemJson(id: 'created'),
        ),
      );

      final item = await source.createItem(listId: 'list-1', name: 'X');

      expect(item.id, 'created');
    });
  });

  group('deleteItem', () {
    test('maps 404 to NotFoundException', () async {
      when(() => dio.delete(any())).thenThrow(
        dioException(statusCode: 404, body: {'message': 'Not found'}),
      );

      expect(
        () => source.deleteItem('x'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
