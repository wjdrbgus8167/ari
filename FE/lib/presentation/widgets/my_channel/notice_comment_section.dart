// lib/presentation/widgets/my_channel/notice_comment_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/my_channel/notice_comment_model.dart';
import '../../../presentation/viewmodels/my_channel/notice_comment_viewmodel.dart';
import '../../../presentation/widgets/common/custom_toast.dart';

/// 공지사항 댓글 섹션 위젯
/// 공지사항 상세 화면에서 사용되는 댓글 목록 및 작성 UI
class NoticeCommentSection extends ConsumerStatefulWidget {
  final int noticeId;

  /// [noticeId] - 댓글을 표시할 공지사항 ID
  const NoticeCommentSection({super.key, required this.noticeId});

  @override
  ConsumerState<NoticeCommentSection> createState() =>
      _NoticeCommentSectionState();
}

class _NoticeCommentSectionState extends ConsumerState<NoticeCommentSection> {
  final _commentController = TextEditingController();
  final _editCommentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 화면 빌드 후 댓글 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editCommentController.dispose();
    super.dispose();
  }

  /// 댓글 목록 로드
  Future<void> _loadComments() async {
    await ref
        .read(noticeCommentProvider.notifier)
        .loadComments(widget.noticeId);
  }

  /// 댓글 작성 처리
  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(noticeCommentProvider.notifier)
          .createComment(content);

      if (success && mounted) {
        _commentController.clear();
        context.showToast('댓글이 등록되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        context.showToast('댓글 등록에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 댓글 수정 처리
  Future<void> _updateComment(NoticeComment comment) async {
    final content = _editCommentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(noticeCommentProvider.notifier)
          .updateComment(comment.commentId, content);

      if (success && mounted) {
        // 수정 모드 종료
        ref
            .read(noticeCommentProvider.notifier)
            .setEditMode(comment.commentId, false);
        context.showToast('댓글이 수정되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        context.showToast('댓글 수정에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 댓글 삭제 처리
  Future<void> _deleteComment(NoticeComment comment) async {
    // 삭제 확인 다이얼로그
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('댓글 삭제', style: TextStyle(color: Colors.white)),
            content: const Text(
              '댓글을 삭제하시겠습니까?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '삭제',
                  style: TextStyle(color: AppColors.mediumPurple),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(noticeCommentProvider.notifier)
          .deleteComment(comment.commentId);

      if (success && mounted) {
        context.showToast('댓글이 삭제되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        context.showToast('댓글 삭제에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(noticeCommentProvider);
    final isLoading = commentState.status == NoticeCommentStatus.loading;
    final comments = commentState.comments;
    final commentCount = commentState.commentCount;

    // 에러 메시지 처리
    final errorMessage = commentState.errorMessage;
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showToast(errorMessage);
        ref.read(noticeCommentProvider.notifier).clearError();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 댓글 헤더 (제목 + 개수)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '댓글',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$commentCount',
                  style: const TextStyle(
                    color: AppColors.mediumPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.mediumPurple,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // 댓글 입력 필드
        _buildCommentInput(),
        const SizedBox(height: 16),

        // 댓글 목록
        if (isLoading && comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.mediumPurple),
            ),
          )
        else if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                '첫 댓글을 작성해보세요!',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(color: Colors.grey, height: 1),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return _buildCommentItem(comment);
            },
          ),
      ],
    );
  }

  /// 댓글 입력 필드
  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 정렬 수정
        children: [
          // 댓글 입력 필드
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // 전송 버튼
          const SizedBox(width: 8),
          InkWell(
            onTap: _isSubmitting ? null : _submitComment,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mediumPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.mediumPurple,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(
                        Icons.send_rounded,
                        color: AppColors.mediumPurple,
                        size: 20,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  /// 댓글 아이템
  Widget _buildCommentItem(NoticeComment comment) {
    // 날짜 포맷팅
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');
    final dateTime = DateTime.parse(comment.createdAt);
    final formattedDate = dateFormatter.format(dateTime);

    // 편집 모드인지 확인
    final isEditing = comment.isEditing;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보 및 날짜
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 프로필 이미지 및 이름
              Row(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[800],
                    backgroundImage:
                        comment.profileImageUrl != null
                            ? NetworkImage(comment.profileImageUrl!)
                            : null,
                    child:
                        comment.profileImageUrl == null
                            ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                  // 작성자 이름
                  Text(
                    comment.memberName,
                    style: TextStyle(
                      color:
                          comment.isMine
                              ? AppColors.mediumPurple
                              : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (comment.isMine) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mediumPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '작성자',
                        style: TextStyle(
                          color: AppColors.mediumPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // 날짜
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 댓글 내용 (수정 모드에 따라 다른 UI)
          if (isEditing)
            _buildEditCommentField(comment)
          else
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                comment.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

          // 자신의 댓글인 경우 수정/삭제 버튼
          if (comment.isMine && !isEditing)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      // 수정 모드 활성화 및 텍스트 필드에 기존 내용 설정
                      _editCommentController.text = comment.content;
                      ref
                          .read(noticeCommentProvider.notifier)
                          .setEditMode(comment.commentId, true);
                    },
                    child: Text(
                      '수정',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => _deleteComment(comment),
                    child: Text(
                      '삭제',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 댓글 수정 필드
  Widget _buildEditCommentField(NoticeComment comment) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 수정 입력 필드
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.mediumPurple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _editCommentController,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 수정 취소/완료 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 취소 버튼
              InkWell(
                onTap: () {
                  ref
                      .read(noticeCommentProvider.notifier)
                      .setEditMode(comment.commentId, false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 완료 버튼
              InkWell(
                onTap: () => _updateComment(comment),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mediumPurple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
