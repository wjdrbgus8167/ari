package com.ccc.ari.community.domain.fantalk.entity;

import lombok.Builder;
import lombok.Getter;

/**
 * Fantalk Channel 도메인 엔티티
 */
@Builder
@Getter
public class FantalkChannel {

    private Integer fantalkChannelId;
    private Integer artistId;

    public FantalkChannel(Integer fantalkChannelId, Integer artistId) {
        this.fantalkChannelId = fantalkChannelId;
        this.artistId = artistId;
    }
}
