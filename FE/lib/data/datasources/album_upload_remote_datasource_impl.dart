import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../core/exceptions/failure.dart';
import '../models/upload_album_request.dart';
import '../models/api_response.dart';
import 'album_upload_remote_datasource.dart';

class AlbumUploadRemoteDataSourceImpl implements AlbumUploadRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AlbumUploadRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<String> uploadAlbum({
    required UploadAlbumRequest albumRequest,
    required File coverImageFile,
    required Map<String, File> trackFiles,
  }) async {
    try {
      print('📀 앨범 업로드 시작: ${albumRequest.albumTitle}');

      // FormData 생성
      final formData = FormData();

      // 메타데이터 구성
      final Map<String, dynamic> metadataMap = {
        "genreName": albumRequest.genreName,
        "albumTitle": albumRequest.albumTitle,
        "description": albumRequest.description,
        "tracks":
            albumRequest.tracks
                .map(
                  (track) => {
                    "trackNumber": track.trackNumber,
                    "trackTitle": track.trackTitle,
                    "composer": track.composer,
                    "lyricist": track.lyricist,
                    "lyrics": track.lyrics,
                  },
                )
                .toList(),
      };

      // JSON으로 변환
      final metadataJson = jsonEncode(metadataMap);
      print('📀 메타데이터(수정됨): $metadataJson');
      formData.fields.add(MapEntry('metadata', metadataJson));

      // 커버 이미지
      final coverFile = await MultipartFile.fromFile(
        coverImageFile.path,
        filename: 'cover.jpg', // 항상 jpg로 통일
      );
      formData.files.add(MapEntry('coverImage', coverFile));
      print('📀 커버 이미지 추가: ${coverImageFile.path}, 파일명: cover.jpg');

      // 트랙 파일 - 하나만 추가
      if (trackFiles.isNotEmpty) {
        final entry = trackFiles.entries.first;
        final trackFile = await MultipartFile.fromFile(
          entry.value.path,
          filename: 'track.mp3',
        );
        formData.files.add(MapEntry('tracks', trackFile));
        print('📀 트랙 파일 추가: ${entry.value.path}, 파일명: track.mp3');
      }

      print(
        '📀 FormData 준비 완료, 필드: ${formData.fields.length}, 파일: ${formData.files.length}',
      );

      // 요청 전송
      final response = await dio.post(
        '$baseUrl/api/v1/albums/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            final percentage = (sent / total * 100).toStringAsFixed(2);
            print('📀 업로드 진행률: $percentage% ($sent/$total)');
          }
        },
      );

      print('📀 서버 응답 코드: ${response.statusCode}');
      print('📀 서버 응답 데이터: ${response.data}');

      // 응답 처리
      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (apiResponse.status == 200) {
        print('📀 앨범 업로드 성공!');
        return apiResponse.message;
      } else {
        print('📀 앨범 업로드 실패: ${apiResponse.error?.message}');
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } catch (e) {
      print('📀 업로드 중 오류 발생: $e');
      if (e is DioException) {
        print('📀 Dio 오류 유형: ${e.type}');
        print('📀 Dio 오류 메시지: ${e.message}');
        if (e.response != null) {
          print('📀 응답 코드: ${e.response?.statusCode}');
          print('📀 응답 데이터: ${e.response?.data}');
        }

        throw Failure(
          message:
              e.response?.data?['error']?['message'] ??
              e.message ??
              '업로드 중 오류가 발생했습니다.',
          code: e.response?.data?['error']?['code'],
          statusCode: e.response?.statusCode,
        );
      }
      throw Failure(message: '업로드 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
