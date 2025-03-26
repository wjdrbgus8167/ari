package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.application.notice.repository.NoticeCommentRepository;
import com.ccc.ari.community.domain.notice.entity.NoticeComment;
import com.ccc.ari.community.infrastructure.notice.entity.NoticeCommentJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

/**
 * 공지사항 댓글 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class NoticeCommentRepositoryImpl implements NoticeCommentRepository {

    private final NoticeCommentJpaRepository noticeCommentJpaRepository;

    @Override
    public void saveNoticeComment(NoticeComment comment) {
        // 1. 도메인 엔티티를 JPA 엔티티로 변환합니다.
        NoticeCommentJpaEntity jpaEntity = NoticeCommentJpaEntity.fromDomain(comment);

        // 2. JPA 리포지토리를 통해 댓글을 저장합니다.
        noticeCommentJpaRepository.save(jpaEntity);
    }
}
