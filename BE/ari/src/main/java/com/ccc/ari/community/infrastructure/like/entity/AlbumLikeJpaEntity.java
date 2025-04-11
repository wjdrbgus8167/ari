package com.ccc.ari.community.infrastructure.like.entity;

import com.ccc.ari.community.domain.like.entity.Like;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "album_likes")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AlbumLikeJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "album_like_id", nullable = false)
    private Integer albumLikeId;

    @Column(name = "album_id", nullable = false)
    private Integer albumId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(name = "activate_yn", nullable = false, columnDefinition = "boolean default true")
    private Boolean activateYn;

    @Builder
    public AlbumLikeJpaEntity(Integer albumLikeId, Integer albumId, Integer memberId, Boolean activateYn) {
        this.albumLikeId = albumLikeId;
        this.albumId = albumId;
        this.memberId = memberId;
        this.activateYn = activateYn != null ? activateYn : true;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static AlbumLikeJpaEntity fromDomain(Like albumLike) {
        return AlbumLikeJpaEntity.builder()
                .albumLikeId(albumLike.getLikeId())
                .albumId(albumLike.getTargetId())
                .memberId(albumLike.getMemberId())
                .activateYn(albumLike.getActivateYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public Like toDomain() {
        return Like.builder()
                .likeId(albumLikeId)
                .targetId(albumId)
                .memberId(memberId)
                .activateYn(activateYn)
                .build();
    }
}
