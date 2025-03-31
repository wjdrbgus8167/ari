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
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final tokens = await getTokensUseCase();
      final accessToken = tokens?.accessToken;

      if (accessToken != null) {
        // Authorization 헤더 대신 쿠키로 토큰 추가
        String cookieHeader = options.headers['Cookie'] ?? '';
        List<String> cookies = [];

        cookies = cookieHeader.split('; ');

        // 기존 access_token 쿠키가 있으면 제거 (중복 방지)
        cookies.removeWhere((cookie) => cookie.startsWith('access_token='));

        // access_token 쿠키로 추가
        cookies.add('access_token=$accessToken');

        // refresh_token이 있으면 추가
        final refreshToken = tokens?.refreshToken;
        if (refreshToken != null) {
          // 기존 refresh_token 쿠키가 있으면 제거
          cookies.removeWhere((cookie) => cookie.startsWith('refresh_token='));
          // refresh_token 쿠키로 추가
          cookies.add('refresh_token=$refreshToken');
        }

        // 쿠키 헤더 설정
        options.headers['Cookie'] = cookies.join('; ');
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
        // 토큰 갱신 시도
        final newTokens = await refreshTokensUseCase();
        if (newTokens != null) {
          // 원래 요청 재시도
          final response = await _retryRequest(
            err.requestOptions,
            newTokens.accessToken,
          );
          return handler.resolve(response);
        }
      } catch (e) {
        print("토큰 갱신 실패: $e");
      }
    }

    return handler.next(err);
  }

  // 재시도 요청을 처리하는 메서드 분리
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) async {
    return await dio.fetch(
      requestOptions.copyWith(
        headers: {
          ...requestOptions.headers,
          'Cookie': _updateCookies(
            requestOptions.headers['Cookie'] ?? '',
            accessToken,
          ),
        },
      ),
    );
  }

  // 쿠키 업데이트 로직 분리
  String _updateCookies(String originalCookies, String accessToken) {
    List<String> cookies =
        originalCookies.isEmpty ? [] : originalCookies.split('; ');
    cookies.removeWhere((cookie) => cookie.startsWith('access_token='));
    cookies.add('access_token=$accessToken');
    return cookies.join('; ');
  }
}
