import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/exceptions/failure.dart';
import '../models/upload_album_request.dart';
import '../models/api_response.dart';
import 'album_upload_remote_datasource.dart';

class AlbumUploadRemoteDataSourceImpl implements AlbumUploadRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AlbumUploadRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<String> uploadAlbum({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
  }) async {
    try {
      // FormData
      final formData = FormData();
      
      // 메타데이터
      formData.fields.add(
        MapEntry('metadata', jsonEncode(albumRequest.toJson())),
      );

      // 커버 이미지
      formData.files.add(
        MapEntry(
          'coverImage',
          await MultipartFile.fromFile(
            coverImageFile.path,
            filename: 'cover.jpg',
          ),
        ),
      );

      // 트랙 파일
      for (final entry in trackFiles.entries) {
        formData.files.add(
          MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              entry.value.path,
              filename: '${entry.key}.mp3',
            ),
          ),
        );
      }

      final response = await dio.post(
        '$baseUrl/api/v1/albums/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getToken()}',
          },
        ),
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.status == 200) {
        return apiResponse.message;
      } else {
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Failure(
          message: e.response?.data?['error']?['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      throw Failure(message: e.toString());
    }
  }

  // JWT 토큰 가져오기 
  Future<String> _getToken() async {
    // SharedPreferences나 Secure Storage에서 토큰 가져오기
    // 여기서는 임시 구현
    return 'your_jwt_token_here';
  }
}