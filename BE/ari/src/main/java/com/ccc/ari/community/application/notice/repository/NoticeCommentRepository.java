package com.ccc.ari.community.application.notice.repository;

import com.ccc.ari.community.domain.notice.entity.NoticeComment;

/**
 * 공지사항 댓글 리포지토리 인터페이스
 */
public interface NoticeCommentRepository {
    // 공지사항 댓글 저장
    void saveNoticeComment(NoticeComment comment);
}
