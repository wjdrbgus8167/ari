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
