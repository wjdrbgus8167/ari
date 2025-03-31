import '../../../data/models/my_channel/artist_notice.dart';
import 'package:dio/dio.dart';

abstract class ArtistNoticeRepository {
  /// 공지사항 목록 조회
  /// [memberId]: 아티스트 회원 ID
  Future<ArtistNoticeResponse> getArtistNotices(String memberId);

  /// 공지사항 상세 정보 조회
  /// [noticeId]: 공지사항 ID
  Future<ArtistNotice> getArtistNoticeDetail(int noticeId);

  /// 공지사항 등록
  /// [noticeContent]: 공지사항 내용
  /// [noticeImage]: 이미지 파일 (선택)
  Future<void> createArtistNotice(String noticeContent, {MultipartFile? noticeImage});
}