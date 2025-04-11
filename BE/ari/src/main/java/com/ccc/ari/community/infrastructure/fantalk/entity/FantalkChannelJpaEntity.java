package com.ccc.ari.community.infrastructure.fantalk.entity;

import com.ccc.ari.community.domain.fantalk.entity.FantalkChannel;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "fantalk_channels")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class FantalkChannelJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "fantalk_channel_id")
    private Integer fantalkChannelId;

    @Column(name = "artist_id")
    private Integer artistId;

    @Builder
    public FantalkChannelJpaEntity(Integer fantalkChannelId, Integer artistId) {
        this.fantalkChannelId = fantalkChannelId;
        this.artistId = artistId;
    }

    public static FantalkChannelJpaEntity fromDomain(FantalkChannel fantalkChannel) {
        return FantalkChannelJpaEntity.builder()
                .fantalkChannelId(fantalkChannel.getFantalkChannelId())
                .artistId(fantalkChannel.getArtistId())
                .build();
    }

    public FantalkChannel toDomain() {
        return FantalkChannel.builder()
                .fantalkChannelId(this.fantalkChannelId)
                .artistId(this.artistId)
                .build();
    }
}
