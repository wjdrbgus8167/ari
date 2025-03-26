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
}
