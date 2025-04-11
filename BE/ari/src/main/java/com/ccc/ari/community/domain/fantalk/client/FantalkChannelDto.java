package com.ccc.ari.community.domain.fantalk.client;

import com.ccc.ari.community.domain.fantalk.entity.FantalkChannel;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FantalkChannelDto {

    private Integer fantalkChannelId;
    private Integer artistId;

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static FantalkChannelDto from(FantalkChannel channel) {
        return FantalkChannelDto.builder()
                .fantalkChannelId(channel.getFantalkChannelId())
                .artistId(channel.getArtistId())
                .build();
    }
}
