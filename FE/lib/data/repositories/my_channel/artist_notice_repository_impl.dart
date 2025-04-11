import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../domain/repositories/my_channel/artist_notice_repository.dart';
import '../../datasources/my_channel/artist_notice_remote_datasource.dart';
import '../../models/my_channel/artist_notice.dart';

class ArtistNoticeRepositoryImpl implements ArtistNoticeRepository {
  final ArtistNoticeRemoteDataSource remoteDataSource;

  ArtistNoticeRepositoryImpl({required this.remoteDataSource});

  /// 공지사항 목록 조회
  @override
  Future<ArtistNoticeResponse> getArtistNotices(String memberId) async {
    try {
      return await remoteDataSource.getArtistNotices(memberId);
    } catch (e) {
      if (e is Failure) {
        rethrow; // 이미 Failure로 변환된 예외는 그대로 전달
      }
      // 기타 예외는 Failure
      throw Failure(message: '😞공지사항 목록 불러오기 실패: ${e.toString()}');
    }
  }

  /// 공지사항 상세 정보 조회
  @override
  Future<ArtistNotice> getArtistNoticeDetail(int noticeId) async {
    try {
      return await remoteDataSource.getArtistNoticeDetail(noticeId);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '😞공지사항 상세 정보 불러오기 실패: ${e.toString()}');
    }
  }

  /// 공지사항 등록
  @override
  Future<void> createArtistNotice(
    String noticeContent, {
    MultipartFile? noticeImage,
  }) async {
    try {
      await remoteDataSource.createArtistNotice(
        noticeContent,
        noticeImage: noticeImage,
      );
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '😞공지사항 등록 실패: ${e.toString()}');
    }
  }
}
