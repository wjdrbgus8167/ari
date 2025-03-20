// dio http client를 사용하여 차트 데이터를 가져오는 데이터 소스

import 'package:dio/dio.dart';
import '../../domain/entities/chart_item.dart';

class ChartRemoteDataSource {
  final Dio dio;

  ChartRemoteDataSource({required this.dio});

  Future<List<ChartItem>> fetchCharts(String baseUrl) async {
    final response = await dio.get('$baseUrl/api/v1/charts');
    if (response.statusCode == 200 && response.data['status'] == 200) {
      final List charts = response.data['data']['charts'];
      return charts.map((chart) => ChartItem.fromJson(chart)).toList();
    } else {
      throw Exception('차트 데이터를 불러오지 못함');
    }
  }
}
