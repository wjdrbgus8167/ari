package com.ccc.ari.community.infrastructure.notice.adapter;

import com.ccc.ari.community.domain.notice.client.NoticeCommentClient;
import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.ccc.ari.community.infrastructure.notice.entity.NoticeCommentJpaEntity;
import com.ccc.ari.community.infrastructure.notice.repository.NoticeCommentJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * NoticeCommentClinet 구현체
 */
@Component
@RequiredArgsConstructor
public class NoticeCommentClientImpl implements NoticeCommentClient {

    private final NoticeCommentJpaRepository noticeCommentJpaRepository;

    @Override
    public List<NoticeCommentDto> getCommentsByNoticeId(Integer noticeId) {
        // 1. JPA 리포지토리를 통해 댓글 엔티티 목록을 조회합니다.
        List<NoticeCommentJpaEntity> jpaEntities = noticeCommentJpaRepository.findByNoticeIdAndDeletedYnFalseOrderByCreatedAtDesc(noticeId);

        // 2. JPA 엔티티 -> 도메인 엔티티 -> DTO로 변환합니다.
        return jpaEntities.stream()
                .map(NoticeCommentJpaEntity::toDomain)
                .map(NoticeCommentDto::from)
                .toList();
    }
}
