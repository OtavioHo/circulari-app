import 'package:dio/dio.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/network/dio_error_mapper.dart';
import 'package:circulari/features/lists/data/models/list_color_model.dart';
import 'package:circulari/features/lists/data/models/list_icon_model.dart';
import 'package:circulari/features/lists/data/models/list_model.dart';
import 'package:circulari/features/lists/data/models/list_picture_model.dart';

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

  Future<List<ListColorModel>> getColors() async {
    try {
      final response = await _dio.get('/lists/colors');
      if (response.data is! List) {
        throw const ServerException('Unexpected response format.');
      }
      return (response.data as List)
          .map((e) => ListColorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ListIconModel>> getIcons() async {
    try {
      final response = await _dio.get('/lists/icons');
      if (response.data is! List) {
        throw const ServerException('Unexpected response format.');
      }
      return (response.data as List)
          .map((e) => ListIconModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ListPictureModel>> getPictures() async {
    try {
      final response = await _dio.get('/lists/pictures');
      if (response.data is! List) {
        throw const ServerException('Unexpected response format.');
      }
      return (response.data as List)
          .map((e) => ListPictureModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<String> createList({
    required String name,
    String? location,
    required String colorId,
    required String iconId,
    required String pictureId,
  }) async {
    try {
      final response = await _dio.post('/lists', data: {
        'name': name,
        'location': ?location,
        'color_id': colorId,
        'icon_id': iconId,
        'picture_id': pictureId,
      });
      final data = response.data;
      if (data is! Map<String, dynamic> || data['id'] is! String) {
        throw const ServerException('Unexpected response format.');
      }
      return data['id'] as String;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> renameList(String id, String name) async {
    try {
      await _dio.patch('/lists/$id', data: {'name': name});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _dio.delete('/lists/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
