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
    await dio.post(
      '/v1/auth/members/register',
      data: signUpRequest,
    );
    
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  @override
  Future<TokenModel?> login(LoginRequest loginRequest) async {
    // API 호출 구현
    final response = await dio.post(
      '/v1/auth/members/login',
      data: loginRequest,
    );
    
    return TokenModel.fromJson(response.data);
  }
}