import '../../models/my_channel/fantalk.dart';
import 'package:dio/dio.dart';

/// 팬톡 목록 조회 및 등록 API 호출 담당
abstract class FantalkRemoteDataSource {
  /// 팬톡 목록 조회
  /// [fantalkChannelId] : 팬톡 채널 ID
  /// [return] : 팬톡 목록 응답 객체
  Future<FanTalkResponse> getFanTalks(String fantalkChannelId);

  /// 팬톡 등록
  /// [fantalkChannelId] : 팬톡 채널 ID
  /// [content] : 팬톡 내용 (필수)
  /// [trackId] : 첨부할 트랙 ID (선택)
  /// [fantalkImage] : 첨부할 이미지 (선택)
  /// [return] : API 호출 성공 여부
  Future<void> createFantalk(
    String fantalkChannelId, {
    required String content,
    int? trackId,
    MultipartFile? fantalkImage,
  });
}
