package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.infrastructure.notice.entity.NoticeCommentJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 공지사항 댓글 JPA 리포지토리 인터페이스
 */
@Repository
public interface NoticeCommentJpaRepository extends JpaRepository<NoticeCommentJpaEntity, Integer> {
    // 공지사항 ID로 댓글 목록 조회 (생성 일시 기준 내림차순 정렬)
    List<NoticeCommentJpaEntity> findByNoticeIdOrderByCreatedAtDesc(Integer noticeId);
}
