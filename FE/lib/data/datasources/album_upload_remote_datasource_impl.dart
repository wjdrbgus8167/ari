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
    Function(double progress)? onProgress, // 콜백 파라미터
  }) async {
    try {
      print('📀 앨범 업로드 시작: ${albumRequest.albumTitle}');

      // FormData 생성
      final formData = FormData();

      // 메타데이터 구성
      final tracksList = <Map<String, dynamic>>[];
      int trackIndex = 1;

      // 트랙 메타데이터 생성 (순차적인 trackNumber로)
      for (final track in albumRequest.tracks) {
        tracksList.add({
          "trackNumber": trackIndex, // 순차적인 트랙 번호 부여
          "trackTitle": track.trackTitle,
          "composer": track.composer,
          "lyricist": track.lyricist,
          "lyrics": track.lyrics,
        });
        trackIndex++;
      }

      final Map<String, dynamic> metadataMap = {
        "genreName": albumRequest.genreName,
        "albumTitle": albumRequest.albumTitle,
        "description": albumRequest.description,
        "tracks": tracksList,
      };

      // JSON으로 변환
      final metadataJson = jsonEncode(metadataMap);
      print('📀 메타데이터(수정됨): $metadataJson');
      formData.fields.add(MapEntry('metadata', metadataJson));

      // 커버 이미지 - 원본 확장자 감지하여 처리
      final imageExt = path.extension(coverImageFile.path).toLowerCase();
      String coverFileName =
          imageExt.contains('.png') ? 'cover.png' : 'cover.jpg';

      final coverFile = await MultipartFile.fromFile(
        coverImageFile.path,
        filename: coverFileName,
      );
      formData.files.add(MapEntry('coverImage', coverFile));
      print('📀 커버 이미지 추가: ${coverImageFile.path}, 파일명: $coverFileName');

      // 중요: 트랙 순서와 이름 설정
      // 서버가 'tracks' 필드에 여러 파일이 올 때 순서를 보장하지 않을 수 있음
      // 따라서 각 트랙 파일에 고유한 필드 이름 부여
      trackIndex = 1;
      for (final entry in trackFiles.entries) {
        final trackFile = await MultipartFile.fromFile(
          entry.value.path,
          filename: 'track$trackIndex.mp3', // 파일명에 순번 포함
        );
        // 여기가 중요: Postman과 동일하게 모든 트랙 파일에 'tracks' 필드명 사용
        formData.files.add(MapEntry('tracks', trackFile));
        print(
          '📀 트랙 파일 추가: ${entry.value.path}, 필드명: tracks, 파일명: track$trackIndex.mp3',
        );
        trackIndex++;
      }

      print(
        '📀 FormData 준비 완료, 필드: ${formData.fields.length}, 파일: ${formData.files.length}',
      );

      // 요청 전송 - 로깅 추가
      print('📀 요청 URL: $baseUrl/api/v1/albums/upload');
      print(
        '📀 요청 헤더: contentType=multipart/form-data, Accept=application/json',
      );

      final response = await dio.post(
        '$baseUrl/api/v1/albums/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
          sendTimeout: const Duration(minutes: 15),
          receiveTimeout: const Duration(minutes: 15),
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = sent / total;
            print(
              '📀 업로드 진행률: ${(progress * 100).toStringAsFixed(2)}% ($sent/$total)',
            );

            // 콜백이 제공된 경우 진행률 전달
            onProgress?.call(progress);
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
