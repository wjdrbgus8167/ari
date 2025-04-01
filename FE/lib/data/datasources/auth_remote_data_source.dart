import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/core/utils/extract_token_from_cookie.dart';
import 'package:ari/data/models/login_request.dart';
import 'package:ari/data/models/token_model.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sign_up_request.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel?> refreshTokens();
  Future<void> signUp(SignUpRequest signUpRequest);
  Future<TokenModel?> login(LoginRequest loginRequest);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Ref ref;
  final String refreshUrl;

  AuthRemoteDataSourceImpl({
    required this.ref,
    required this.refreshUrl,
  });

  @override
  Future<TokenModel?> refreshTokens() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        refreshUrl,
      );

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
          return TokenModel(accessToken: accessToken, refreshToken: refreshToken);
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signUp(SignUpRequest signUpRequest) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://ari-music.duckdns.org',
        contentType: 'application/json',
      ));
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
    // API 호출 구
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://ari-music.duckdns.org',
        contentType: 'application/json',
      ));
      debugPrint('로그인 요청 시작: ${loginRequest.email}');
      debugPrint('요청 URL: ${dio.options.baseUrl}/api/v1/auth/members/login');
      
      final response = await dio.post(
        '/api/v1/auth/members/login',
        data: loginRequest.toJson(),
        options: Options(
          // 쿠키를 받기 위한 설정
          validateStatus: (status) => true,
          receiveDataWhenStatusError: true,
        ),
      );
      
      // 응답 로그
      debugPrint('로그인 응답 코드: ${response.statusCode}');
      debugPrint('로그인 응답 데이터: ${response.data}');
      debugPrint(response.toString());

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
          return TokenModel(accessToken: accessToken, refreshToken: refreshToken);
        }
        print("널이다");
        return null;
      }
    } catch (e) {
      // DioError 또는 기타 예외 처리
      print(e.toString());
      if (e is DioException) {
        // Dio 에러 정보를 사용하여 에러 응답 생성
        throw Failure(message: "에러가 났음요");
      } else {
        // 기타 예외 처리
        throw Failure(message: "에러가 났음요");
      }
    }
  }
}