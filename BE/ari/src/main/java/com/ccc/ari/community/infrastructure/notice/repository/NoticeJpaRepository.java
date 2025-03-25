package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.infrastructure.notice.entity.NoticeJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 공지사항 JPA 리포지토리 인터페이스
 */
@Repository
public interface NoticeJpaRepository extends JpaRepository<NoticeJpaEntity, Integer> {
}
