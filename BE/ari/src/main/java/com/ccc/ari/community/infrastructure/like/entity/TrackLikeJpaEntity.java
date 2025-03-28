package com.ccc.ari.community.infrastructure.like.entity;

import com.ccc.ari.community.domain.like.entity.Like;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "track_likes")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrackLikeJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "track_like_id", nullable = false)
    private Integer trackLikeId;

    @Column(name = "track_id", nullable = false)
    private Integer trackId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(name = "activate_yn", nullable = false, columnDefinition = "boolean default true")
    private Boolean activateYn;

    @Builder
    public TrackLikeJpaEntity(Integer trackLikeId, Integer trackId, Integer memberId, Boolean activateYn) {
        this.trackLikeId = trackLikeId;
        this.trackId = trackId;
        this.memberId = memberId;
        this.activateYn = activateYn != null ? activateYn : true;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static TrackLikeJpaEntity fromDomain(Like like) {
        return TrackLikeJpaEntity.builder()
                .trackLikeId(like.getLikeId())
                .trackId(like.getTargetId())
                .memberId(like.getMemberId())
                .activateYn(like.getActivateYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public Like toDomain() {
        return Like.builder()
                .likeId(trackLikeId)
                .targetId(trackId)
                .memberId(memberId)
                .activateYn(activateYn)
                .build();
    }
}
