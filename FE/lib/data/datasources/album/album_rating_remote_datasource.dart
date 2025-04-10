import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:dio/dio.dart';

/// 앨범 평점을 다루는 Data Source 인터페이스
abstract class AlbumRatingDataSource {
  /// [albumId] 앨범에 [rating] 평점을 부여하는 API 호출.
  Future<ApiResponse<void>> rateAlbum(int albumId, double rating);
}

/// 실제 Dio를 사용하여 API 요청을 보내는 구현체
class AlbumRatingDataSourceImpl implements AlbumRatingDataSource {
  final Dio dio;

  AlbumRatingDataSourceImpl({required this.dio});

  @override
  Future<ApiResponse<void>> rateAlbum(int albumId, double rating) async {
    final url = '/api/v1/albums/$albumId/ratings';
    try {
      // Dio를 사용해 POST 요청 보내기 (body의 key, value는 백엔드 스펙에 맞게 조정)
      final response = await dio.post(url, data: {'rating': rating});
      // ApiResponse로 변환 (만약 응답 데이터가 없으면, mapping callback으로 null 반환)
      final apiResponse = ApiResponse.fromJson(response.data, (json) => null);
      if (apiResponse.status == 200) {
        return apiResponse;
      } else {
        throw Failure(message: "앨범 평점 등록 실패: ${apiResponse.message}");
      }
    } on DioError catch (e) {
      throw Failure(message: "네트워크 에러 발생: ${e.message}");
    } catch (e) {
      throw Failure(message: "알 수 없는 에러 발생: $e");
    }
  }
}
