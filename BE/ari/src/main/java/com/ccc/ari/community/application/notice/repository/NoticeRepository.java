package com.ccc.ari.community.application.notice.repository;

import com.ccc.ari.community.domain.notice.entity.Notice;

/**
 * 공지사항 리포지토리 인터페이스
 */
public interface NoticeRepository {
    // 공지사항 저장
    Notice saveNotice(Notice notice);
}
