import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/user_plan_model.dart';

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
}
