package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.application.notice.repository.NoticeRepository;
import com.ccc.ari.community.domain.notice.entity.Notice;
import com.ccc.ari.community.infrastructure.notice.entity.NoticeJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

/**
 * 공지사항 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class NoticeRepositoryImpl implements NoticeRepository {

    private final NoticeJpaRepository noticeJpaRepository;

    @Override
    public Notice saveNotice(Notice notice) {
        // 1. 도메인 엔티티를 JPA 엔티티로 변환합니다.
        NoticeJpaEntity jpaEntity = NoticeJpaEntity.fromDomain(notice);

        // 2. JPA 리포지토리를 통해 공지사항을 저장합니다.
        NoticeJpaEntity savedNotice = noticeJpaRepository.save(jpaEntity);

        // 3. 저장된 JPA 엔티티를 다시 도메인 엔티티로 변환하여 반환합니다.
        return savedNotice.toDomain();
    }
}
