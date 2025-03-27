package com.ccc.ari.community.domain.follow.entity;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Follow 도메인 엔티티
 */
@Getter
@Builder
public class Follow {

    private Integer memberFollowId;
    private Integer followerId;
    private Integer followingId;
    private LocalDateTime createdAt;
    @Builder.Default
    private Boolean activateYn = true;

    // 팔로우 취소
    public void deactivate() {
        this.activateYn = false;
    }

    // 팔로우 재활성화
    public void activate() {
        this.activateYn = true;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Follow follow) {
            return follow.getMemberFollowId().equals(memberFollowId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(memberFollowId);
    }
}
