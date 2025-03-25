import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/login_request.dart';
import 'package:ari/data/models/token_model.dart';
import 'package:dio/dio.dart';

import '../models/sign_up_request.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel?> refreshTokens(String refreshToken);
  Future<void> signUp(SignUpRequest signUpRequest);
  Future<TokenModel?> login(LoginRequest loginRequest);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String refreshUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.refreshUrl,
  });

  @override
  Future<TokenModel?> refreshTokens(String refreshToken) async {
    try {
      final response = await dio.post(
        refreshUrl,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TokenModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signUp(SignUpRequest signUpRequest) async {
    // API 호출 구현
    print('로그인 요청 시작: ${signUpRequest.toString()}');
    print('요청 URL: ${dio.options.baseUrl}/v1/auth/members/register');
    await dio.post(
      '/v1/auth/members/register',
      data: signUpRequest,
    );
    
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  @override
  Future<TokenModel?> login(LoginRequest loginRequest) async {
    // API 호출 구

    try {
      // 요청 전 로그
      print('로그인 요청 시작: ${loginRequest.toString()}');
      print('요청 URL: ${dio.options.baseUrl}/v1/auth/members/login');
      
      final response = await dio.post(
        '/v1/auth/members/login',
        data: loginRequest.toJson(),
      );
      
      // 응답 로그
      print('로그인 응답 코드: ${response.statusCode}');
      print('로그인 응답 데이터: ${response.data}');
      print(response);

      if (response.statusCode == 200) {
        return TokenModel.fromJson(response.data);
      } else {
        throw Failure(
          message: response.statusMessage as String
        );
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