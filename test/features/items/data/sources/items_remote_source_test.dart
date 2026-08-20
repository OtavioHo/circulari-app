import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/data/sources/items_remote_source.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';

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
    void stubGet(dynamic data) => when(() => dio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/lists/list-1/items'),
              statusCode: 200,
              data: data,
            ));

    test('parses items, nextCursor, and totalValue from the envelope',
        () async {
      stubGet({
        'data': [okItemJson()],
        'nextCursor': 'cur-1',
        'totalValue': 1234,
      });

      final result = await source.getItems('list-1');

      expect(result.data, hasLength(1));
      expect(result.data.first.id, 'i1');
      expect(result.nextCursor, 'cur-1');
      expect(result.hasMore, isTrue);
      // Whole-list total, parsed from int to double.
      expect(result.totalValue, 1234.0);
    });

    test('totalValue is null when the server omits it (older backend)',
        () async {
      stubGet({
        'data': [okItemJson()],
        'nextCursor': null,
      });

      final result = await source.getItems('list-1');

      expect(result.totalValue, isNull);
    });

    test('returns null cursor on the last page', () async {
      stubGet({
        'data': [okItemJson()],
        'nextCursor': null,
      });

      final result = await source.getItems('list-1');

      expect(result.nextCursor, isNull);
      expect(result.hasMore, isFalse);
    });

    test('forwards cursor and limit as query parameters', () async {
      stubGet({'data': <Map<String, dynamic>>[], 'nextCursor': null});

      await source.getItems('list-1', cursor: 'cur-1', limit: 100);

      final query = verify(() => dio.get(
            '/lists/list-1/items',
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured.single as Map<String, dynamic>;
      expect(query['cursor'], 'cur-1');
      expect(query['limit'], 100);
    });

    test('omits cursor and limit when not provided', () async {
      stubGet({'data': <Map<String, dynamic>>[], 'nextCursor': null});

      await source.getItems('list-1');

      final query = verify(() => dio.get(
            any(),
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured.single as Map<String, dynamic>;
      expect(query, isEmpty);
    });

    test('throws ServerException when envelope is missing data array',
        () async {
      stubGet({'data': 'not-a-list'});

      expect(() => source.getItems('list-1'), throwsA(isA<ServerException>()));
    });

    test('maps DioException → AppException', () async {
      when(() => dio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(dioException(statusCode: 500, body: {}));

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

  group('analyzeImage', () {
    late File tempImage;

    setUp(() async {
      tempImage = File(
        '${Directory.systemTemp.path}/analyze_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await tempImage.writeAsBytes([0xFF, 0xD8, 0xFF]);
    });

    tearDown(() async {
      if (tempImage.existsSync()) await tempImage.delete();
    });

    Map<String, dynamic> okAnalysisJson() => {
          'name': 'Camisa',
          'category': 'Roupas',
          'category_id': 'cat-9',
          'description': 'Camisa usada.',
          'price_min': 40,
          'price_max': 90,
        };

    test('parses price_confidence and price_evidence', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: {
            ...okAnalysisJson(),
            'price_confidence': 'high',
            'price_evidence': [
              {'title': 'Camisa usada', 'price': 55, 'url': 'https://olx.com.br/x'},
              {'title': 'Sem url', 'price': 60}, // dropped: missing url
            ],
          },
        ),
      );

      final result = await source.analyzeImage(tempImage.path);

      expect(result.priceConfidence, PriceConfidence.high);
      expect(result.priceEvidence, hasLength(1));
      expect(result.priceEvidence.first.title, 'Camisa usada');
      expect(result.priceEvidence.first.price, 55.0);
      expect(result.priceEvidence.first.url, 'https://olx.com.br/x');
    });

    test('defaults to low confidence and empty evidence when fields are absent', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: okAnalysisJson(),
        ),
      );

      final result = await source.analyzeImage(tempImage.path);

      expect(result.priceConfidence, PriceConfidence.low);
      expect(result.priceEvidence, isEmpty);
    });

    test('parses correction fields (analysis_id, alternatives, conflict, free retry)', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: {
            ...okAnalysisJson(),
            'analysis_id': 'analysis-1',
            'alternatives': [
              {'name': 'iPhone 15'},
              {'name': ''}, // dropped: empty
              {'nope': 'x'}, // dropped: missing name
              {'name': 'iPhone 13'},
            ],
            'conflicts_with_image': true,
            'conflict_note': 'A foto se parece mais com um iPhone 14.',
            'free_retry_available': true,
          },
        ),
      );

      final result = await source.analyzeImage(tempImage.path);

      expect(result.analysisId, 'analysis-1');
      expect(result.alternatives, ['iPhone 15', 'iPhone 13']);
      expect(result.conflictsWithImage, isTrue);
      expect(result.conflictNote, 'A foto se parece mais com um iPhone 14.');
      expect(result.freeRetryAvailable, isTrue);
    });

    test('defaults correction fields when absent (pre-M1 response shape)', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: okAnalysisJson(),
        ),
      );

      final result = await source.analyzeImage(tempImage.path);

      expect(result.analysisId, isNull);
      expect(result.alternatives, isEmpty);
      expect(result.conflictsWithImage, isFalse);
      expect(result.conflictNote, isNull);
      expect(result.freeRetryAvailable, isFalse);
    });

    test('sends hint and parent_analysis_id as multipart fields on a refine', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: okAnalysisJson(),
        ),
      );

      await source.analyzeImage(
        tempImage.path,
        hint: 'é um iPhone 15',
        parentAnalysisId: 'analysis-1',
      );

      final formData = verify(
        () => dio.post(any(), data: captureAny(named: 'data'), options: any(named: 'options')),
      ).captured.single as FormData;
      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['hint'], 'é um iPhone 15');
      expect(fields['parent_analysis_id'], 'analysis-1');
    });

    test('omits hint and parent_analysis_id fields on a plain analysis', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: okAnalysisJson(),
        ),
      );

      await source.analyzeImage(tempImage.path);

      final formData = verify(
        () => dio.post(any(), data: captureAny(named: 'data'), options: any(named: 'options')),
      ).captured.single as FormData;
      final keys = formData.fields.map((f) => f.key).toSet();
      expect(keys.contains('hint'), isFalse);
      expect(keys.contains('parent_analysis_id'), isFalse);
    });

    test('analyzeItem sends item_id (and correction fields) with no image part', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/ai/analyze'),
          statusCode: 200,
          data: okAnalysisJson(),
        ),
      );

      await source.analyzeItem(
        'item-1',
        hint: 'é um iPhone 15',
        parentAnalysisId: 'analysis-1',
      );

      final formData = verify(
        () => dio.post(any(), data: captureAny(named: 'data'), options: any(named: 'options')),
      ).captured.single as FormData;
      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['item_id'], 'item-1');
      expect(fields['hint'], 'é um iPhone 15');
      expect(fields['parent_analysis_id'], 'analysis-1');
      expect(formData.files, isEmpty);
    });

    test('createItem sends ai_analysis_id on the multipart create', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/items'),
          statusCode: 201,
          data: okItemJson(),
        ),
      );

      await source.createItem(
        listId: 'list-1',
        name: 'X',
        imagePath: tempImage.path,
        aiAnalysisId: 'analysis-1',
      );

      final formData = verify(() => dio.post(any(), data: captureAny(named: 'data')))
          .captured
          .single as FormData;
      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['ai_analysis_id'], 'analysis-1');
    });

    test('updateItem sends ai_analysis_id in the JSON body', () async {
      when(() => dio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/items/i1'),
          statusCode: 200,
          data: okItemJson(),
        ),
      );

      await source.updateItem('i1', name: 'Y', aiAnalysisId: 'analysis-1');

      final body = verify(() => dio.patch(any(), data: captureAny(named: 'data')))
          .captured
          .single as Map<String, dynamic>;
      expect(body['ai_analysis_id'], 'analysis-1');
    });

    test('maps 429 to RateLimitException', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(dioException(statusCode: 429, body: {}));

      await expectLater(
        () => source.analyzeImage(tempImage.path),
        throwsA(isA<RateLimitException>()),
      );
    });
  });
}
