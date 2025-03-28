package com.ccc.ari.community.domain.like.entity;

import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

/**
 * 좋아요 도메인 엔티티
 */
@Getter
@Builder
public class Like {

    private Integer likeId;
    private Integer targetId;
    private Integer memberId;
    @Builder.Default
    private Boolean activateYn = true;

    // 좋아요 취소
    public void deactivate() {
        this.activateYn = false;
    }

    // 좋아요
    public void activate() {
        this.activateYn = true;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Like like) {
            return like.getLikeId().equals(likeId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(likeId);
    }
}
