import 'package:dio/dio.dart';

import 'package:circulari/core/network/dio_error_mapper.dart';
import 'package:circulari/features/profile/data/models/user_plan_model.dart';

class ProfileRemoteSource {
  final Dio _dio;

  const ProfileRemoteSource(this._dio);

  Future<UserPlanModel> getPlan() async {
    try {
      final response = await _dio.get('/plan');
      return UserPlanModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserPlanModel> reconcilePlan() async {
    try {
      final response = await _dio.post('/plan/reconcile');
      return UserPlanModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
