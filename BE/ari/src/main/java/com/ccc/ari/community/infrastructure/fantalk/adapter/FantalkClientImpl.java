package com.ccc.ari.community.infrastructure.fantalk.adapter;

import com.ccc.ari.community.domain.fantalk.client.FantalkClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkDto;
import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkJpaEntity;
import com.ccc.ari.community.infrastructure.fantalk.repository.FantalkJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * FantalkClient 구현체
 */
@Component
@RequiredArgsConstructor
public class FantalkClientImpl implements FantalkClient {

    private final FantalkJpaRepository fantalkJpaRepository;

    @Override
    public List<FantalkDto> getFantalksByChannelId(Integer channelId) {
        // 1. JPA 리포지토리를 통해 팬톡 엔티티 목록을 조회합니다.
        List<FantalkJpaEntity> jpaEntities = fantalkJpaRepository.findByFantalkChannelIdOrderByCreatedAtDesc(channelId);

        // 2. JPA 엔티티 -> 도메인 엔티티 -> DTO로 변환합니다.
        return jpaEntities.stream()
                .map(jpaEntity -> jpaEntity.toDomain())
                .map(fantalk -> FantalkDto.from(fantalk))
                .toList();
    }
}
