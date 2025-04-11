import 'package:dio/dio.dart';
import '../../repositories/my_channel/artist_notice_repository.dart';
import '../../../data/models/my_channel/artist_notice.dart';

/// 아티스트 공지사항 목록 조회 유스케이스
class GetArtistNoticesUseCase {
  final ArtistNoticeRepository repository;

  GetArtistNoticesUseCase(this.repository);

  Future<ArtistNoticeResponse> call(String memberId) {
    return repository.getArtistNotices(memberId);
  }
}

/// 공지사항 상세 정보 조회 유스케이스
class GetArtistNoticeDetailUseCase {
  final ArtistNoticeRepository repository;

  GetArtistNoticeDetailUseCase(this.repository);

  Future<ArtistNotice> call(int noticeId) {
    return repository.getArtistNoticeDetail(noticeId);
  }
}

/// 공지사항 등록 유스케이스
class CreateArtistNoticeUseCase {
  final ArtistNoticeRepository repository;

  CreateArtistNoticeUseCase(this.repository);

  /// 공지사항 등록 실행
  /// [noticeContent]: 공지 내용, [noticeImage]: 이미지 파일 (선택)
  Future<void> call(String noticeContent, {MultipartFile? noticeImage}) {
    return repository.createArtistNotice(
      noticeContent,
      noticeImage: noticeImage,
    );
  }
}
