package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 팬톡 JPA 리포지토리 인터페이스
 */
@Repository
public interface FantalkJpaRepository extends JpaRepository<FantalkJpaEntity, Integer> {
    // 채널 ID로 팬톡 목록 조회 (생성 일시 기준 내림차순 정렬)
    List<FantalkJpaEntity> findByFantalkChannelIdOrderByCreatedAtDesc(Integer fantalkChannelId);
}
