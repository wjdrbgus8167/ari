import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/core/utils/extract_token_from_cookie.dart';
import 'package:ari/data/models/login_request.dart';
import 'package:ari/data/models/token_model.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sign_up_request.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel?> refreshTokens();
  Future<void> signUp(SignUpRequest signUpRequest);
  Future<TokenModel?> login(LoginRequest loginRequest);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Ref ref;
  final String refreshUrl;

  AuthRemoteDataSourceImpl({required this.ref, required this.refreshUrl});

  @override
  Future<TokenModel?> refreshTokens() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(refreshUrl);

      // 응답 헤더에서 쿠키 가져오기
      final cookies = response.headers.map['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        String? accessToken;
        String? refreshToken;

        for (var cookie in cookies) {
          if (cookie.contains('accessToken=')) {
            accessToken = extractTokenFromCookie(cookie, 'accessToken=');
          }
          if (cookie.contains('refreshToken=')) {
            refreshToken = extractTokenFromCookie(cookie, 'refreshToken=');
          }
        }

        // 토큰이 있으면 저장하거나 사용
        if (accessToken != null && refreshToken != null) {
          return TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> signUp(SignUpRequest signUpRequest) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://ari-music.duckdns.org',
          contentType: 'application/json',
        ),
      );
      print('회원가입 요청 시작: ${signUpRequest.toString()}');
      print('요청 URL: ${dio.options.baseUrl}/api/v1/auth/members/register');

      await dio.post(
        '/api/v1/auth/members/register',
        data: signUpRequest.toJson(),
      );

      print('회원가입 성공!');
    } catch (e) {
      print('회원가입 오류 발생: $e');
      rethrow; // 호출자에게 오류 전달
    }
  }

  @override
  Future<TokenModel?> login(LoginRequest loginRequest) async {
    try {
      debugPrint("여기는옴?");
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://ari-music.duckdns.org',
          contentType: 'application/json',
        ),
      );
      debugPrint('로그인 요청 시작: ${loginRequest.email}');
      debugPrint('요청 URL: ${dio.options.baseUrl}/api/v1/auth/members/login');

      final response = await dio.post(
        '/api/v1/auth/members/login',
        data: loginRequest.toJson(),
        options: Options(
          // 400 등의 에러 상태 코드에서 예외 발생
          validateStatus: (status) => status == 200,
          
        ),
      );

      // 응답 로그
      debugPrint('로그인 응답 코드: ${response.statusCode}');
      debugPrint('로그인 응답 데이터: ${response.data}');

      // 응답 헤더에서 쿠키 가져오기
      final cookies = response.headers.map['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        debugPrint(cookies.toString());
        String? accessToken;
        String? refreshToken;

        for (var cookie in cookies) {
          if (cookie.contains('access_token=')) {
            accessToken = extractTokenFromCookie(cookie, 'access_token=');
          }
          if (cookie.contains('refresh_token=')) {
            refreshToken = extractTokenFromCookie(cookie, 'refresh_token=');
          }
        }
        
        // 토큰이 있으면 저장하거나 사용
        if (accessToken != null && refreshToken != null) {
          print(accessToken);
          return TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        print("토큰이 없습니다");
        throw Failure(message: "토큰을 찾을 수 없습니다");
      }

      // 쿠키가 없는 경우
      throw Failure(message: "로그인 실패");
    } on DioException catch (e) {
      // Dio 특정 예외 처리
      debugPrint('Dio 에러: ${e.response?.data}');
      
      // 서버에서 보낸 에러 메시지 활용
      final errorMessage = e.response?.data?['error']?['message'] ?? '로그인 중 오류가 발생했습니다';
      throw Failure(message: errorMessage);
    } catch (e) {
      // 기타 예외 처리
      debugPrint('기타 에러: $e');
      throw Failure(message: "로그인 중 예상치 못한 오류가 발생했습니다");
    }
  }
}
