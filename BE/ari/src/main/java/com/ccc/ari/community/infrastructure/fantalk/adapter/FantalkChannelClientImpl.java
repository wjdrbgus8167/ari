package com.ccc.ari.community.infrastructure.fantalk.adapter;

import com.ccc.ari.community.domain.fantalk.client.FantalkChannelClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkChannelDto;
import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkChannelJpaEntity;
import com.ccc.ari.community.infrastructure.fantalk.repository.FantalkChannelJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class FantalkChannelClientImpl implements FantalkChannelClient {

    private final FantalkChannelJpaRepository fantalkChannelJpaRepository;

    @Override
    public FantalkChannelDto getFantalkChannelByArtistId(Integer artistId) {
        FantalkChannelJpaEntity jpaEntity = fantalkChannelJpaRepository.findByArtistId(artistId);
        return FantalkChannelDto.from(jpaEntity.toDomain());
    }
}
