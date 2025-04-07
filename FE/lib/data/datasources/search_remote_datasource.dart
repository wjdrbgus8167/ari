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

  /// 검색어로 아티스트, 트랙 검색
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

      // 응답 로깅
      print('검색 API 응답: ${response.data}');

      // API 응답 처리
      if (response.data == null) {
        throw Failure(message: '서버 응답이 없습니다');
      }

      // Map이 아닌 경우 처리
      if (response.data is! Map<String, dynamic>) {
        // 응답 본문이 Map이 아니면 SearchResponse로 변환 불가능
        print('응답 형식 오류: ${response.data.runtimeType}');
        return SearchResponse(artists: [], tracks: []);
      }

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) =>
            json != null
                ? SearchResponse.fromJson(json as Map<String, dynamic>)
                : SearchResponse(artists: [], tracks: []),
      );

      // 오류 확인
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? '검색 중 오류가 발생했습니다',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      // 결과가 null인 경우 빈 결과 반환
      if (apiResponse.data == null) {
        return SearchResponse(artists: [], tracks: []);
      }

      // 검색 결과 반환
      return apiResponse.data as SearchResponse;
    } on DioException catch (e) {
      print(
        'DioException 발생: ${e.message}, 응답 상태 코드: ${e.response?.statusCode}',
      );
      print('응답 데이터: ${e.response?.data}');

      throw Failure(
        message: e.message ?? '네트워크 오류가 발생했습니다',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('알 수 없는 오류 발생: $e');

      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '검색 중 알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
