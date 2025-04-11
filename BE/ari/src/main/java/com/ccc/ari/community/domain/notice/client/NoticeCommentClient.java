package com.ccc.ari.community.domain.notice.client;

import java.util.List;

/**
 * 공지사항 댓글 도메인에 접근하기 위한 클라이언트 인터페이스
 */
public interface NoticeCommentClient {
    // 공지사항 댓글 전체 목록 조회
    List<NoticeCommentDto> getCommentsByNoticeId(Integer noticeId);
}
