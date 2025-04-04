package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkChannelJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * 팬톡 채널 JPA 리포지토리
 */
public interface FantalkChannelJpaRepository extends JpaRepository<FantalkChannelJpaEntity, Integer> {

}
