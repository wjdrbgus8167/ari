package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkChannelJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 팬톡 채널 JPA 리포지토리
 */
@Repository
public interface FantalkChannelJpaRepository extends JpaRepository<FantalkChannelJpaEntity, Integer> {

    FantalkChannelJpaEntity findByArtistId(Integer artistId);
}
