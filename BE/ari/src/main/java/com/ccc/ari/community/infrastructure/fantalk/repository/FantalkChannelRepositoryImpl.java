package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.application.fantalk.repository.FantalkChannelRepository;
import com.ccc.ari.community.domain.fantalk.entity.FantalkChannel;
import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkChannelJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class FantalkChannelRepositoryImpl implements FantalkChannelRepository {

    private final FantalkChannelJpaRepository fantalkChannelJpaRepository;

    @Override
    public void saveFantalkChannel(FantalkChannel fantalkChannel) {
        // 1. 도메인 엔티티를 JPA 엔티티로 변환합니다.
        FantalkChannelJpaEntity jpaEntity = FantalkChannelJpaEntity.fromDomain(fantalkChannel);

        // 2. JPA 리포지토리를 통해 팬톡 채널을 생성합니다.
        fantalkChannelJpaRepository.save(jpaEntity);
    }
}
