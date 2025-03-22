class Failure {
  final String message;
  final int? statusCode;

  Failure({required this.message, this.statusCode});

  @override
  String toString() {
    return 'Failure: $message (code: $statusCode)';
  }
}