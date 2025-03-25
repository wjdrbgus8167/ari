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