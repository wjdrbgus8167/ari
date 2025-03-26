import 'package:ari/domain/usecases/auth_usecase.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final RefreshTokensUseCase refreshTokensUseCase;
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final GetTokensUseCase getTokensUseCase;
  final Dio dio;
  
  AuthInterceptor({
    required this.refreshTokensUseCase,
    required this.getAuthStatusUseCase,
    required this.getTokensUseCase,
    required this.dio,
  });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final tokens = await getTokensUseCase();
      final accessToken = tokens?.accessToken;
      
      print("요청 전 토큰: $tokens");
      print("Authorization 헤더 추가: Bearer $accessToken");
      
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      
      print("최종 요청 헤더: ${options.headers}");
      print("요청 URL: ${options.path}");
      
      handler.next(options);
    } catch (e) {
      print("요청 인터셉터 오류: $e");
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 처리 (인증 실패)
    print(err);
    if (err.response?.statusCode == 401) {
      return handler.next(err);
    }
      
      // 토큰 갱신 시도
    final newTokens = await refreshTokensUseCase();
    if (newTokens != null) {
      // 원래 요청 재시도
      final options = Options(
        method: err.requestOptions.method,
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer ${newTokens.accessToken}',
        },
      );
        
      try {
        final response = await dio.request(
          err.requestOptions.path,
          options: options,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    return handler.next(err);
  }
}
