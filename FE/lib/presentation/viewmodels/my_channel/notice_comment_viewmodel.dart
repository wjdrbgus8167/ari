import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/notice_comment_model.dart';
import '../../../domain/usecases/my_channel/notice_comment_usecases.dart';
import '../../../providers/my_channel/notice_comment_providers.dart';

/// 공지사항 댓글 상태 관리를 위한 enum
enum NoticeCommentStatus {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 로드 완료
  error, // 오류 발생
  creating, // 댓글 생성 중
  updating, // 댓글 수정 중
  deleting, // 댓글 삭제 중
}

/// 공지사항 댓글 상태 클래스
class NoticeCommentState {
  final NoticeCommentStatus status;
  final List<NoticeComment> comments;
  final int commentCount;
  final String? errorMessage;
  final int currentNoticeId;

  const NoticeCommentState({
    this.status = NoticeCommentStatus.initial,
    this.comments = const [],
    this.commentCount = 0,
    this.errorMessage,
    this.currentNoticeId = 0,
  });

  /// 상태 복사본 생성
  NoticeCommentState copyWith({
    NoticeCommentStatus? status,
    List<NoticeComment>? comments,
    int? commentCount,
    String? errorMessage,
    int? currentNoticeId,
  }) {
    return NoticeCommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
      errorMessage: errorMessage,
      currentNoticeId: currentNoticeId ?? this.currentNoticeId,
    );
  }
}

/// 공지사항 댓글 ViewModel: 댓글 관련 비즈니스 로직 및 상태 관리
class NoticeCommentNotifier extends StateNotifier<NoticeCommentState> {
  final GetNoticeCommentsUseCase getNoticeCommentsUseCase;
  final CreateNoticeCommentUseCase createNoticeCommentUseCase;
  final UpdateNoticeCommentUseCase updateNoticeCommentUseCase;
  final DeleteNoticeCommentUseCase deleteNoticeCommentUseCase;

  NoticeCommentNotifier({
    required this.getNoticeCommentsUseCase,
    required this.createNoticeCommentUseCase,
    required this.updateNoticeCommentUseCase,
    required this.deleteNoticeCommentUseCase,
  }) : super(const NoticeCommentState());

  /// 댓글 목록 로드
  Future<void> loadComments(int noticeId) async {
    try {
      state = state.copyWith(
        status: NoticeCommentStatus.loading,
        currentNoticeId: noticeId,
      );

      final commentsResponse = await getNoticeCommentsUseCase(noticeId);

      state = state.copyWith(
        status: NoticeCommentStatus.loaded,
        comments: commentsResponse.comments,
        commentCount: commentsResponse.commentCount,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: '댓글을 불러오는데 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// 새 댓글 작성
  Future<bool> createComment(String content) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(errorMessage: '댓글 내용을 입력해주세요.');
      return false;
    }

    try {
      state = state.copyWith(status: NoticeCommentStatus.creating);

      await createNoticeCommentUseCase(state.currentNoticeId, content);

      // 댓글 작성 후 목록 새로고침
      await loadComments(state.currentNoticeId);
      return true;
    } on Failure catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: '댓글 작성에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// 댓글 수정 모드 설정
  void setEditMode(int commentId, bool isEditing) {
    final comments = [...state.comments];
    final index = comments.indexWhere((c) => c.commentId == commentId);
    if (index != -1) {
      comments[index] = comments[index].copyWith(isEditing: isEditing);
      state = state.copyWith(comments: comments);
    }
  }

  /// 댓글 수정
  Future<bool> updateComment(int commentId, String content) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(errorMessage: '댓글 내용을 입력해주세요.');
      return false;
    }

    try {
      state = state.copyWith(status: NoticeCommentStatus.updating);

      await updateNoticeCommentUseCase(
        state.currentNoticeId,
        commentId,
        content,
      );

      // 댓글 수정 후 목록 새로고침
      await loadComments(state.currentNoticeId);
      return true;
    } on Failure catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: '댓글 수정에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int commentId) async {
    try {
      state = state.copyWith(status: NoticeCommentStatus.deleting);

      await deleteNoticeCommentUseCase(state.currentNoticeId, commentId);

      // 댓글 삭제 후 목록 새로고침
      await loadComments(state.currentNoticeId);
      return true;
    } on Failure catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: NoticeCommentStatus.error,
        errorMessage: '댓글 삭제에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// 오류 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 공지사항 댓글 Provider
final noticeCommentProvider = StateNotifierProvider<
  NoticeCommentNotifier,
  NoticeCommentState
>((ref) {
  return NoticeCommentNotifier(
    getNoticeCommentsUseCase: ref.read(getNoticeCommentsUseCaseProvider),
    createNoticeCommentUseCase: ref.read(createNoticeCommentUseCaseProvider),
    updateNoticeCommentUseCase: ref.read(updateNoticeCommentUseCaseProvider),
    deleteNoticeCommentUseCase: ref.read(deleteNoticeCommentUseCaseProvider),
  );
});
