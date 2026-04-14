import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/item_model.dart';

class ItemsRemoteSource {
  final Dio _dio;
  const ItemsRemoteSource(this._dio);

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
    String? locationId,
    double? userDefinedValue,
  }) async {
    try {
      final body = <String, dynamic>{
        'list_id': listId,
        'name': name,
        'quantity': quantity,
        'description': ?description,
        'location_id': ?locationId,
        'user_defined_value': ?userDefinedValue,
      };
      final response = await _dio.post('/items', data: body);
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
    String? locationId,
    double? userDefinedValue,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': ?name,
        'description': ?description,
        'quantity': ?quantity,
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

  Map<String, dynamic> _parseMap(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Unexpected response format.');
    }
    return data;
  }
}
