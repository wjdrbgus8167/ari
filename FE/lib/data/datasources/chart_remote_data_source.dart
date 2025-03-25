// dio 를 사용하여 차트 데이터를 가져오는 데이터 소스
import 'package:dio/dio.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/data/models/api_response.dart'; // ApiResponse
import 'package:ari/core/exceptions/failure.dart'; // Failure

class ChartRemoteDataSource {
  final Dio dio;

  ChartRemoteDataSource({required this.dio});

  /// 서버에서 차트 데이터를 가져와서 Domain Entity인 ChartItem 리스트로 반환
  Future<List<ChartItem>> fetchCharts(String baseUrl) async {
    try {
      final response = await dio.get('$baseUrl/api/v1/charts');

      // 1) ApiResponse로 안전하게 파싱
      final apiResponse = ApiResponse.fromJson(response.data, (data) {
        // data는 response.data['data']가 될 것이며, 그 안에 charts가 있다고 가정
        final chartsJson = data['charts'] as List;
        return chartsJson.map((c) => ChartItem.fromJson(c)).toList();
      });

      // 2) 상태 코드 체크
      if (apiResponse.status == 200 && apiResponse.data != null) {
        // 3) 성공 시 data(차트 목록) 반환
        return apiResponse.data!;
      } else {
        // 4) 실패 시 Failure로 변환하여 throw
        throw Failure.fromApiResponse(apiResponse);
      }
    } on DioException catch (dioError) {
      // 5) Dio 에러 → Failure 변환
      throw Failure.fromDioException(dioError);
    } catch (e) {
      // 6) 그 외 예외 → Failure 변환
      throw Failure.fromException(e is Exception ? e : Exception(e));
    }
  }
}
