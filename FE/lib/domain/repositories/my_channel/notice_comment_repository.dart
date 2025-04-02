import 'package:dio/dio.dart';
import '../../../data/models/my_channel/notice_comment_model.dart';

/// 공지사항 댓글 리포지토리 인터페이스
/// 댓글 관련 데이터 접근 로직을 추상화하는 인터페이스
abstract class NoticeCommentRepository {
  /// 공지사항의 댓글 목록 조회
  /// [noticeId]: 댓글을 조회할 공지사항 ID
  /// 성공 시 댓글 목록과 댓글 수가 포함된 [NoticeCommentsResponse] 반환
  Future<NoticeCommentsResponse> getNoticeComments(int noticeId);
  
  /// 새 댓글 등록
  /// [noticeId]: 댓글을 추가할 공지사항 ID
  /// [content]: 댓글 내용
  Future<void> createNoticeComment(int noticeId, String content);
  
  /// 댓글 수정
  /// [noticeId]: 댓글이 속한 공지사항 ID
  /// [commentId]: 수정할 댓글 ID
  /// [content]: 새 댓글 내용
  Future<void> updateNoticeComment(int noticeId, int commentId, String content);
  
  /// 댓글 삭제
  /// [noticeId]: 댓글이 속한 공지사항 ID
  /// [commentId]: 삭제할 댓글 ID
  Future<void> deleteNoticeComment(int noticeId, int commentId);
}