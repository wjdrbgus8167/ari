import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/data/models/user/profile_model.dart';
import 'package:dio/dio.dart';


abstract class UserRemoteDataSource {
  Future<ProfileResponse?> getUserProfile();
  Future<void> updateUserProfile(UpdateProfileRequest profileRequest);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({
    required this.apiClient,
  });
  
  @override
  Future<ProfileResponse?> getUserProfile() {
    return apiClient.request<ProfileResponse>(
      url: '/api/v1/mypages/profile',
      method: 'GET',
      fromJson: (data) => ProfileResponse.fromJson(data), // 화살표 함수로 수정, return 추가
    );
  }
    
  @override
  Future<void> updateUserProfile(UpdateProfileRequest updateProfileRequest) {
    return apiClient.request<void>(
      url: '/api/v1/mypages/profile',
      method: 'PUT',
      data: updateProfileRequest.toFormData(),
      options: Options(
        contentType: 'multipart/form-data', // 명시적으로 설정
      ),
      fromJson: (_) {}, 
    );
  }
}