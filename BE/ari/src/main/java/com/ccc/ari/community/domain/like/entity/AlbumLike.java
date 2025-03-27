package com.ccc.ari.community.domain.like.entity;

import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

@Getter
@Builder
public class AlbumLike {

    private Integer albumLikeId;
    private Integer albumId;
    private Integer memberId;
    @Builder.Default
    private Boolean activateYn = true;

    // 좋아요 취소
    public void deactivate() {
        this.activateYn = false;
    }

    // 좋아요 활성화
    public void activate() {
        this.activateYn = true;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof AlbumLike albumLike) {
            return Objects.equals(albumLike.getAlbumLikeId(), albumLikeId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(albumLikeId);
    }
}
