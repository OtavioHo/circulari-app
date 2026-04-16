import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/ai_analysis_result.dart';
import '../../domain/entities/category.dart';
import '../models/item_model.dart';

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

  Future<AiAnalysisResult> analyzeImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post('/ai/analyze', data: formData);
      final map = _parseMap(response.data);
      return AiAnalysisResult(
        name: map['name'] as String,
        category: map['category'] as String?,
        categoryId: map['category_id'] as String?,
        description: map['description'] as String,
        priceMin: (map['price_min'] as num).toDouble(),
        priceMax: (map['price_max'] as num).toDouble(),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _parseMap(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response format.');
    }
    return data;
  }
}
