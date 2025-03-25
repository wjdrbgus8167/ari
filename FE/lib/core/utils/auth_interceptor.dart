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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await getTokensUseCase();
    final accessToken = tokens?.accessToken;
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 처리 (인증 실패)
    if (err.response?.statusCode == 401) {
      // 리프레시 토큰 요청 또는 로그인 요청이면 재시도하지 않음
      if (err.requestOptions.path.contains('/auth/refresh') || 
          err.requestOptions.path.contains('/auth/login')) {
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
    }
    
    // 다른 에러는 그대로 전달
    return handler.next(err);
  }
}
