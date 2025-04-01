// lib/domain/usecases/my_channel/notice_comment_usecases.dart

import '../../../data/models/my_channel/notice_comment_model.dart';
import '../../../domain/repositories/my_channel/notice_comment_repository.dart';

/// 공지사항 댓글 목록 조회 유스케이스
class GetNoticeCommentsUseCase {
  final NoticeCommentRepository repository;

  GetNoticeCommentsUseCase(this.repository);

  /// 유스케이스 실행: 댓글 목록 조회
  /// [noticeId]: 댓글을 조회할 공지사항 ID
  Future<NoticeCommentsResponse> call(int noticeId) {
    return repository.getNoticeComments(noticeId);
  }
}

/// 공지사항 댓글 등록 유스케이스
class CreateNoticeCommentUseCase {
  final NoticeCommentRepository repository;

  CreateNoticeCommentUseCase(this.repository);

  /// 유스케이스 실행: 새 댓글 등록
  /// [noticeId]: 댓글을 추가할 공지사항 ID
  /// [content]: 댓글 내용
  Future<void> call(int noticeId, String content) {
    return repository.createNoticeComment(noticeId, content);
  }
}

/// 공지사항 댓글 수정 유스케이스
class UpdateNoticeCommentUseCase {
  final NoticeCommentRepository repository;

  UpdateNoticeCommentUseCase(this.repository);

  /// 유스케이스 실행: 댓글 수정
  /// [noticeId]: 댓글이 속한 공지사항 ID
  /// [commentId]: 수정할 댓글 ID
  /// [content]: 새 댓글 내용
  Future<void> call(int noticeId, int commentId, String content) {
    return repository.updateNoticeComment(noticeId, commentId, content);
  }
}

/// 공지사항 댓글 삭제 유스케이스
class DeleteNoticeCommentUseCase {
  final NoticeCommentRepository repository;

  DeleteNoticeCommentUseCase(this.repository);

  /// 유스케이스 실행: 댓글 삭제
  /// [noticeId]: 댓글이 속한 공지사항 ID
  /// [commentId]: 삭제할 댓글 ID
  Future<void> call(int noticeId, int commentId) {
    return repository.deleteNoticeComment(noticeId, commentId);
  }
}
