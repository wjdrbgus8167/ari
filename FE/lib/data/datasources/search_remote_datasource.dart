import 'package:dio/dio.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:ari/data/models/search_response.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/core/exceptions/failure.dart';

/// 검색 관련 API 호출을 담당
/// 검색어를 받아 서버에 요청하고 검색 결과(아티스트, 트랙) 반환
class SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSource({required this.dio});

  /// 검색어로 아티스트와 트랙을 검색
  ///
  /// [query] 검색어
  /// [return] 검색 결과 (아티스트 목록, 트랙 목록)
  Future<SearchResponse> searchContent(String query) async {
    try {
      // 검색어가 비어있는 경우 빈 결과 반환
      if (query.trim().isEmpty) {
        return SearchResponse(artists: [], tracks: []);
      }

      // 검색 API 호출
      final response = await dio.get(
        '$baseUrl/api/v1/search',
        queryParameters: {'q': query},
      );

      // API 응답 처리
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => SearchResponse.fromJson(json),
      );

      // 오류 확인
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? '검색 중 오류가 발생했습니다',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      // 검색 결과 반환
      return apiResponse.data as SearchResponse;
    } on DioException catch (e) {
      throw Failure(
        message: e.message ?? '네트워크 오류가 발생했습니다',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '검색 중 알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
