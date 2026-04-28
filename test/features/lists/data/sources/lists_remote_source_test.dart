import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/lists/data/sources/lists_remote_source.dart';

import '../../../../helpers/dio_helpers.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ListsRemoteSource source;

  setUp(() {
    dio = MockDio();
    source = ListsRemoteSource(dio);
  });

  Map<String, dynamic> okListJson({String id = 'l1'}) => {
        'id': id,
        'name': 'List',
        'color': {'hex_code': '#FF0000', 'name': 'Red', 'order': 0},
        'icon': {'slug': 'home', 'name': 'Home', 'order': 0},
        'picture': {'slug': 'nature', 'order': 0},
        'item_count': 0,
        'total_value': 0.0,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

  group('getLists', () {
    test('parses a list of lists', () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/lists'),
            statusCode: 200,
            data: [okListJson()],
          ));

      final lists = await source.getLists();

      expect(lists, hasLength(1));
      expect(lists.first.id, 'l1');
    });

    test('throws ServerException on non-list payload', () async {
      when(() => dio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/lists'),
            statusCode: 200,
            data: {'wrong': 'shape'},
          ));

      expect(() => source.getLists(), throwsA(isA<ServerException>()));
    });

    test('maps DioException to AppException', () async {
      when(() => dio.get(any())).thenThrow(dioConnectionError());

      expect(() => source.getLists(), throwsA(isA<NetworkException>()));
    });
  });

  group('createList', () {
    test('maps 403 LIMIT_REACHED to PlanLimitException', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioException(
          statusCode: 403,
          body: {'code': 'LIMIT_REACHED', 'limit': 5},
        ),
      );

      await expectLater(
        () => source.createList(
          name: 'X',
          colorId: '#FF0000',
          iconId: 'home',
          pictureId: 'nature',
        ),
        throwsA(isA<PlanLimitException>()),
      );
    });

    test('omits null location from payload', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/lists'),
          statusCode: 201,
        ),
      );

      await source.createList(
        name: 'X',
        location: null,
        colorId: '#FF0000',
        iconId: 'home',
        pictureId: 'nature',
      );

      final captured = verify(
        () => dio.post(any(), data: captureAny(named: 'data')),
      ).captured.single as Map<String, dynamic>;
      expect(captured.containsKey('location'), isFalse);
      expect(captured['name'], 'X');
      expect(captured['color_id'], '#FF0000');
    });
  });

  group('renameList', () {
    test('PATCHes /lists/:id with new name', () async {
      when(() => dio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/lists/abc'),
          statusCode: 200,
        ),
      );

      await source.renameList('abc', 'New Name');

      verify(() => dio.patch('/lists/abc', data: {'name': 'New Name'}))
          .called(1);
    });

    test('maps 404 to NotFoundException', () async {
      when(() => dio.patch(any(), data: any(named: 'data')))
          .thenThrow(dioException(statusCode: 404, body: {'message': 'no'}));

      expect(
        () => source.renameList('abc', 'X'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteList', () {
    test('DELETEs /lists/:id', () async {
      when(() => dio.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/lists/abc'),
          statusCode: 204,
        ),
      );

      await source.deleteList('abc');

      verify(() => dio.delete('/lists/abc')).called(1);
    });
  });
}
