import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/list_model.dart';

class ListsRemoteSource {
  final Dio _dio;
  const ListsRemoteSource(this._dio);

  Future<List<ListModel>> getLists() async {
    try {
      final response = await _dio.get('/lists');
      if (response.data is! List) {
        throw const ServerException('Unexpected response format.');
      }
      return (response.data as List)
          .map((e) {
            if (e is! Map<String, dynamic>) {
              throw const ServerException('Unexpected list item format.');
            }
            return ListModel.fromJson(e);
          })
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ListModel> createList(String name) async {
    try {
      final response = await _dio.post('/lists', data: {'name': name});
      return ListModel.fromJson(_parseMap(response.data));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<ListModel> renameList(String id, String name) async {
    try {
      final response =
          await _dio.patch('/lists/$id', data: {'name': name});
      return ListModel.fromJson(_parseMap(response.data));
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

  Future<void> deleteList(String id) async {
    try {
      await _dio.delete('/lists/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
