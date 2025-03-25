import 'package:ari/data/models/api_response.dart';
import 'package:dio/dio.dart';

class Failure {
  final String message;
  final String? code;
  final int? statusCode;

  Failure({required this.message, this.code, this.statusCode});

  @override
  String toString() {
    return 'Failure: $message (code: $code, status: $statusCode)';
  }

  // ApiResponse에서 Failure 생성
  factory Failure.fromApiResponse(ApiResponse response) {
    return Failure(
      message: response.error?.message ?? 'Unknown error',
      code: response.error?.code,
      statusCode: response.status,
    );
  }

  // DioException에서 Failure 생성
  factory Failure.fromDioException(DioException dioException) {
    return Failure(
      message: dioException.message ?? 'Network error',
      statusCode: dioException.response?.statusCode,
    );
  }

  // 일반 예외에서 Failure 생성
  factory Failure.fromException(Exception exception) {
    return Failure(message: exception.toString(), statusCode: 400);
  }
}
