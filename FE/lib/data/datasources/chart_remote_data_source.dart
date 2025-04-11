import 'package:dio/dio.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/data/models/api_response.dart';

class ChartRemoteDataSource {
  final Dio dio;

  ChartRemoteDataSource({required this.dio});

  /// 서버에서 차트 데이터를 가져와서 ChartItem 리스트로 변환
  Future<List<ChartItem>> fetchCharts() async {
    try {
      final response = await dio.get('/api/v1/charts');

      final apiResponse = ApiResponse.fromJson(response.data, (data) {
        final chartsJson = data['charts'] as List;
        return chartsJson.map((c) => ChartItem.fromJson(c)).toList();
      });

      if (apiResponse.status == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception('API 요청 실패: ${apiResponse.message}');
      }
    } on DioException catch (dioError) {
      throw Exception('Dio 에러 발생: ${dioError.message}');
    } catch (e) {
      throw Exception('예기치 못한 오류 발생: $e');
    }
  }
}
