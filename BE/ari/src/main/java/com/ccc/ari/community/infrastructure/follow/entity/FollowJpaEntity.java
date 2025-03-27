package com.ccc.ari.community.infrastructure.follow.entity;

import com.ccc.ari.community.domain.follow.entity.Follow;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Follow JPA 엔티티
 */
@Entity
@Table(name = "member_follows")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FollowJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_follow_id", nullable = false)
    private Integer memberFollowId;

    @Column(name = "follower_id", nullable = false)
    private Integer followerId;

    @Column(name = "following_id", nullable = false)
    private Integer followingId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "activate_yn", nullable = false, columnDefinition = "boolean default true")
    private Boolean activateYn;

    @Builder
    public FollowJpaEntity(Integer memberFollowId, Integer followerId, Integer followingId, LocalDateTime createdAt, Boolean activateYn) {
        this.memberFollowId = memberFollowId;
        this.followerId = followerId;
        this.followingId = followingId;
        this.createdAt = createdAt;
        this.activateYn = activateYn;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static FollowJpaEntity fromDomain(Follow follow) {
        return FollowJpaEntity.builder()
                .memberFollowId(follow.getMemberFollowId())
                .followerId(follow.getFollowerId())
                .followingId(follow.getFollowingId())
                .createdAt(follow.getCreatedAt())
                .activateYn(follow.getActivateYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public Follow toDomain() {
        return Follow.builder()
                .memberFollowId(memberFollowId)
                .followerId(followerId)
                .followingId(followingId)
                .createdAt(createdAt)
                .activateYn(activateYn)
                .build();
    }
}
