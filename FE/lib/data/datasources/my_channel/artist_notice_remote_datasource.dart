import 'package:dio/dio.dart';
import '../../models/my_channel/artist_notice.dart';

/// 아티스트 공지사항 관련 API 호출을 위한 datasource 인터페이스
abstract class ArtistNoticeRemoteDataSource {
  /// 공지사항 목록 조회 (아티스트 채널 페이지용)
  /// [memberId]: 아티스트 회원 ID
  Future<ArtistNoticeResponse> getArtistNotices(String memberId);

  /// 공지사항 상세 조회
  /// [noticeId]: 조회할 공지사항 ID
  Future<ArtistNotice> getArtistNoticeDetail(int noticeId);

  /// 공지사항 등록 (이미지 포함 가능)
  /// [noticeContent]: 공지사항 내용
  /// [noticeImage]: 선택적 이미지 파일 (multipart/form-data)
  Future<void> createArtistNotice(
    String noticeContent, {
    MultipartFile? noticeImage,
  });
}
