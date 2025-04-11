package com.ccc.ari.community.application.notice.repository;

import com.ccc.ari.community.domain.notice.entity.Notice;

import java.util.List;
import java.util.Optional;

/**
 * 공지사항 리포지토리 인터페이스
 */
public interface NoticeRepository {
    // 공지사항 저장
    void saveNotice(Notice notice);

    // 공지사항 목록 조회
    List<Notice> findAll(Integer artistId);

    // 공지사항 개수 조회
    int countByArtistId(Integer artistId);

    // 공지사항 상세 조회
    Optional<Notice> findById(Integer noticeId);

    // 최근 공지사항 조회
    Optional<Notice> findByMemberId(Integer memberId);
}
