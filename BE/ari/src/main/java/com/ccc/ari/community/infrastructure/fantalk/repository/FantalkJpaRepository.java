package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 팬톡 JPA 리포지토리 인터페이스
 */
@Repository
public interface FantalkJpaRepository extends JpaRepository<FantalkJpaEntity, Integer> {
}
