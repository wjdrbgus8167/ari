import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../models/my_channel/fantalk.dart';
import '../api_client.dart';
import 'fantalk_remote_datasource.dart';
import 'dart:convert';

/// 팬톡 원격 데이터소스 구현체
/// API 클라이언트를 사용하여 실제 API 호출 구현
class FantalkRemoteDataSourceImpl implements FantalkRemoteDataSource {
  final ApiClient apiClient;

  FantalkRemoteDataSourceImpl({required this.apiClient});

  /// 팬톡 목록 조회 API 호출
  /// [fantalkChannelId] : 팬톡 채널 ID
  /// [return] : 팬톡 목록 응답 객체
  @override
  Future<FanTalkResponse> getFanTalks(String fantalkChannelId) async {
    try {
      final response = await apiClient.dio.get(
        '/api/v1/fantalk-channels/$fantalkChannelId/fantalks',
      );

      // 응답 상태 코드와 status 필드로 성공 여부 확인
      if (response.statusCode == 200 && response.data['status'] == 200) {
        // data 필드가 있는지 확인
        if (response.data['data'] != null) {
          return FanTalkResponse.fromJson(response.data['data']);
        } else {
          // data 필드가 null인 경우 빈 응답 반환
          return FanTalkResponse(
            fantalks: [],
            fantalkCount: 0,
            subscribedYn: false,
          );
        }
      } else {
        throw Failure(
          message: response.data['message'] ?? '팬톡 목록 조회에 실패했습니다.',
          code: response.data['status']?.toString() ?? '500',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
        message: e.toString(),
        code: e is DioException ? '${e.response?.statusCode}' : '500',
      );
    }
  }

  /// 팬톡 등록 API 호출
  /// [fantalkChannelId] : 팬톡 채널 ID
  /// [content] : 팬톡 내용 (필수)
  /// [trackId] : 첨부할 트랙 ID (선택)
  /// [fantalkImage] : 첨부할 이미지 (선택)
  /// [return] : API 호출 성공 여부
  @override
  Future<void> createFantalk(
    String fantalkChannelId, {
    required String content,
    int? trackId,
    MultipartFile? fantalkImage,
  }) async {
    try {
      Map<String, dynamic> requestData = {'content': content};

      // 트랙 ID가 있는 경우
      if (trackId != null) {
        requestData['trackId'] = trackId;
      }

      // 폼데이터 준비
      FormData formData;

      // 이미지가 있는 경우
      if (fantalkImage != null) {
        formData = FormData.fromMap({
          // request 필드에 추가
          'request': jsonEncode(requestData),
          'fantalkImage': fantalkImage,
        });
      } else {
        // 이미지가 없는 경우
        formData = FormData.fromMap({'request': jsonEncode(requestData)});
      }

      // API 호출
      final response = await apiClient.dio.post(
        '/api/v1/fantalk-channels/$fantalkChannelId/fantalks',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data', // 항상 멀티파트로 
        ),
      );

      // 응답 처리
      if (response.statusCode != 200 || response.data['status'] != 200) {
        throw Failure(
          message: response.data['message'] ?? '팬톡 등록에 실패했습니다.',
          code: response.data['status']?.toString() ?? '500',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
        message: e.toString(),
        code: e is DioException ? '${e.response?.statusCode}' : '500',
      );
    }
  }
}
