package com.ccc.ari.community.infrastructure.fantalk.entity;

import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import com.ccc.ari.community.domain.fantalk.vo.FantalkContent;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 팬톡 JPA 엔티티
 */
@Entity
@Table(name = "fantalks")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class FantalkJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "fantalk_id")
    private Integer fantalkId;

    @Column(name = "fantalk_channel_id", nullable = false)
    private Integer fantalkChannelId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(name = "track_id")
    private Integer trackId;

    @Column(nullable = false, length = 1000)
    private String content;

    @Column(name = "fantalk_image_url", length = 2000)
    private String fantalkImageUrl;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    /**
     * JPA 엔티티 생성자
     */
    @Builder
    public FantalkJpaEntity(Integer fantalkId, Integer fantalkChannelId, Integer memberId, Integer trackId, String content, String fantalkImageUrl, LocalDateTime createdAt) {
        this.fantalkId = fantalkId;
        this.fantalkChannelId = fantalkChannelId;
        this.memberId = memberId;
        this.trackId = trackId;
        this.content = content;
        this.fantalkImageUrl = fantalkImageUrl;
        this.createdAt = createdAt;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static FantalkJpaEntity fromDomain(Fantalk fantalk) {
        return new FantalkJpaEntity(
                fantalk.getFantalkId(),
                fantalk.getFantalkChannelId(),
                fantalk.getMemberId(),
                fantalk.getContent().getTrackId(),
                fantalk.getContent().getContent(),
                fantalk.getContent().getFantalkImageUrl(),
                fantalk.getCreatedAt()
        );
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public Fantalk toDomain() {
        FantalkContent content = new FantalkContent(this.content, this.trackId, this.fantalkImageUrl);

        return Fantalk.builder()
                .fantalkId(this.fantalkId)
                .fantalkChannelId(this.fantalkChannelId)
                .memberId(this.memberId)
                .content(content)
                .createdAt(this.createdAt)
                .build();
    }
}
