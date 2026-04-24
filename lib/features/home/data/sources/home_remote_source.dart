import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../models/dashboard_summary_model.dart';

class HomeRemoteSource {
  final Dio _dio;

  const HomeRemoteSource(this._dio);

  Future<DashboardSummaryModel> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      return DashboardSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
