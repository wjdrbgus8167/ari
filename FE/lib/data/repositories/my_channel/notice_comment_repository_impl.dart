// lib/data/repositories/my_channel/notice_comment_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/failure.dart';
import '../../datasources/my_channel/notice_comment_remote_datasource.dart';
import '../../models/my_channel/notice_comment_model.dart';
import '../../../domain/repositories/my_channel/notice_comment_repository.dart';
import '../../../providers/user_provider.dart';

/// 공지사항 댓글 리포지토리 구현체
/// 데이터 소스 레이어와 도메인 레이어 사이의 중간 역할
class NoticeCommentRepositoryImpl implements NoticeCommentRepository {
  final NoticeCommentRemoteDataSource remoteDataSource;
  final Ref ref;

  NoticeCommentRepositoryImpl({
    required this.remoteDataSource,
    required this.ref,
  });

  /// 공지사항의 댓글 목록 조회 구현
  @override
  Future<NoticeCommentsResponse> getNoticeComments(int noticeId) async {
    try {
      // 원격 데이터 소스를 통해 댓글 목록 조회
      final commentsResponse = await remoteDataSource.getNoticeComments(
        noticeId,
      );

      // 사용자 정보를 통해 내 댓글 여부 표시
      final currentUserId = ref.read(userIdProvider);

      if (currentUserId != null) {
        for (var i = 0; i < commentsResponse.comments.length; i++) {
          final comment = commentsResponse.comments[i];
          if (comment.memberId.toString() == currentUserId) {
            commentsResponse.comments[i] = comment.copyWith(isMine: true);
          }
        }
      }

      return commentsResponse;
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '댓글 목록을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// 새 댓글 등록 구현
  @override
  Future<void> createNoticeComment(int noticeId, String content) async {
    try {
      await remoteDataSource.createNoticeComment(noticeId, content);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '댓글 등록에 실패했습니다: ${e.toString()}');
    }
  }

  /// 댓글 수정 구현
  @override
  Future<void> updateNoticeComment(
    int noticeId,
    int commentId,
    String content,
  ) async {
    try {
      await remoteDataSource.updateNoticeComment(noticeId, commentId, content);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '댓글 수정에 실패했습니다: ${e.toString()}');
    }
  }

  /// 댓글 삭제 구현
  @override
  Future<void> deleteNoticeComment(int noticeId, int commentId) async {
    try {
      await remoteDataSource.deleteNoticeComment(noticeId, commentId);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '댓글 삭제에 실패했습니다: ${e.toString()}');
    }
  }
}
