import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/models/paginated_result.dart';
import 'package:circulari/core/network/dio_error_mapper.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/data/models/item_model.dart';

class ItemsRemoteSource {
  final Dio _dio;
  const ItemsRemoteSource(this._dio);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final list = response.data;
      if (list is! List) throw const ServerException('Unexpected response format.');
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return Category(id: map['id'] as String, name: map['name'] as String);
      }).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ItemModel>> getItems(String listId) async {
    try {
      final response = await _dio.get('/lists/$listId/items');
      if (response.data is! Map<String, dynamic>) {
        throw const ServerException('Unexpected response format.');
      }
      final envelope = response.data as Map<String, dynamic>;
      final list = envelope['data'];
      if (list is! List) {
        throw const ServerException('Unexpected response format.');
      }
      return list.map((e) {
        if (e is! Map<String, dynamic>) {
          throw const ServerException('Unexpected item format.');
        }
        return ItemModel.fromJson(e);
      }).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<PaginatedResult<ItemModel>> searchItems({
    String? search,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _dio.get('/items', queryParameters: {
        'search': ?search,
        'cursor': ?cursor,
        'limit': ?limit,
      });
      if (response.data is! Map<String, dynamic>) {
        throw const ServerException('Unexpected response format.');
      }
      final envelope = response.data as Map<String, dynamic>;
      final list = envelope['data'];
      if (list is! List) {
        throw const ServerException('Unexpected response format.');
      }
      final items = list.map((e) {
        if (e is! Map<String, dynamic>) {
          throw const ServerException('Unexpected item format.');
        }
        return ItemModel.fromJson(e);
      }).toList();
      return PaginatedResult(
        data: items,
        nextCursor: envelope['nextCursor'] as String?,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ItemModel> createItem({
    required String listId,
    required String name,
    String? description,
    int quantity = 1,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
    String? imagePath,
  }) async {
    try {
      final Response response;
      if (imagePath != null) {
        final formData = FormData.fromMap({
          'list_id': listId,
          'name': name,
          'quantity': quantity.toString(),
          'description': ?description,
          'category_id': ?categoryId,
          'location_id': ?locationId,
          'user_defined_value': ?(userDefinedValue?.toString()),
          'image': await MultipartFile.fromFile(imagePath),
        });
        response = await _dio.post('/items', data: formData);
      } else {
        final body = <String, dynamic>{
          'list_id': listId,
          'name': name,
          'quantity': quantity,
          'description': ?description,
          'category_id': ?categoryId,
          'location_id': ?locationId,
          'user_defined_value': ?userDefinedValue,
        };
        response = await _dio.post('/items', data: body);
      }
      return ItemModel.fromJson(_parseMap(response.data));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ItemModel> updateItem(
    String id, {
    String? name,
    String? description,
    int? quantity,
    String? categoryId,
    String? locationId,
    double? userDefinedValue,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': ?name,
        'description': ?description,
        'quantity': ?quantity,
        'category_id': ?categoryId,
        'location_id': ?locationId,
        'user_defined_value': ?userDefinedValue,
      };
      final response = await _dio.patch('/items/$id', data: body);
      return ItemModel.fromJson(_parseMap(response.data));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _dio.delete('/items/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ItemModel> uploadItemImage(String itemId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post(
        '/items/$itemId/images',
        data: formData,
      );
      return ItemModel.fromJson(_parseMap(response.data));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AiAnalysisResult> analyzeImage(
    String imagePath, {
    String? hint,
    String? parentAnalysisId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        // Correction refine: the user's hint plus the analysis it corrects
        // (unlocks that analysis's free retry when unspent).
        'hint': ?hint,
        'parent_analysis_id': ?parentAnalysisId,
      });
      // Grounded analysis (vision + web search) legitimately takes 9-37s, and
      // the backend's own worst case is ~65s (Gemini 45s + OpenAI fallback 20s).
      // The global 10s receiveTimeout is far too short here, so override it for
      // this one slow endpoint.
      final response = await _dio.post(
        '/ai/analyze',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final map = _parseMap(response.data);
      final result = AiAnalysisResult(
        analysisId: map['analysis_id'] as String?,
        name: map['name'] as String,
        category: map['category'] as String?,
        categoryId: map['category_id'] as String?,
        description: map['description'] as String,
        priceMin: (map['price_min'] as num).toDouble(),
        priceMax: (map['price_max'] as num).toDouble(),
        priceConfidence: _parseConfidence(map['price_confidence']),
        priceEvidence: _parseEvidence(map['price_evidence']),
        alternatives: _parseAlternatives(map['alternatives']),
        conflictsWithImage: map['conflicts_with_image'] == true,
        conflictNote: map['conflict_note'] as String?,
        freeRetryAvailable: map['free_retry_available'] == true,
      );
      debugPrint('[analyzeImage] OK confidence=${result.priceConfidence.name} '
          'evidence=${result.priceEvidence.length}');
      return result;
    } on DioException catch (e) {
      debugPrint('[analyzeImage] DioException type=${e.type} '
          'status=${e.response?.statusCode} message=${e.message}');
      throw mapDioError(e);
    } on AppException {
      rethrow; // already a domain error (e.g. bad-shape ServerException)
    } catch (e) {
      // Any other failure (e.g. an unexpected body shape causing a cast error)
      // must become an AppException — otherwise the cubit, which only catches
      // AppException, never emits Failure and the UI hangs on "loading".
      debugPrint('[analyzeImage] unexpected error: $e');
      throw ServerException('Failed to parse AI analysis.');
    }
  }

  Map<String, dynamic> _parseMap(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response format.');
    }
    return data;
  }

  PriceConfidence _parseConfidence(dynamic value) {
    return switch (value) {
      'high' => PriceConfidence.high,
      'medium' => PriceConfidence.medium,
      _ => PriceConfidence.low,
    };
  }

  List<String> _parseAlternatives(dynamic value) {
    if (value is! List) return const [];
    return [
      for (final entry in value)
        if (entry is Map && entry['name'] is String && (entry['name'] as String).isNotEmpty)
          entry['name'] as String,
    ];
  }

  List<PriceComp> _parseEvidence(dynamic value) {
    if (value is! List) return const [];
    final comps = <PriceComp>[];
    for (final entry in value) {
      if (entry is! Map) continue;
      final title = entry['title'];
      final url = entry['url'];
      final price = entry['price'];
      if (title is String &&
          title.isNotEmpty &&
          url is String &&
          url.isNotEmpty &&
          price is num) {
        comps.add(PriceComp(title: title, price: price.toDouble(), url: url));
      }
    }
    return comps;
  }
}
