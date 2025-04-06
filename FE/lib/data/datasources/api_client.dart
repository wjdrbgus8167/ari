import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  /// API 요청 처리, 결과를 반환하는 제네릭 메서드
  /// 
  /// [url]: API 엔드포인트 URL
  /// [method]: HTTP 메서드 (GET, POST, DELETE 등)
  /// [fromJson]: API 응답 데이터를 객체로 변환하는 함수
  /// [queryParameters]: URL 쿼리 파라미터
  /// [data]: 요청 본문 데이터
  /// 
  /// 반환값: 변환된 응답 데이터 객체
  /// 오류 발생 시 Failure 객체 throw
  Future<T> request<T>({
    required String url,
    required String method,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'DELETE':
          response = await dio.delete(url, queryParameters: queryParameters);
          break;
        case 'PUT':
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        default:
          throw Failure(message: '지원하지 않는 HTTP 메서드입니다: $method');
      }

      // API 응답 처리
      final apiResponse = ApiResponse.fromJson(response.data, fromJson);
      // 오류 check
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
      // 응답 데이터 반환
      return apiResponse.data as T;

    } on DioException catch (e) {
      throw Failure(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '😞알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}