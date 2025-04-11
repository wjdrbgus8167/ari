package com.ccc.ari.community.domain.rating.entity;

import com.ccc.ari.community.domain.rating.vo.Rating;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AlbumRating {
    private Integer memberId;
    private Integer albumId;
    private Rating rating;
    private LocalDateTime updatedAt;

    public void updateRating(Rating newRating) {
        this.rating = newRating;
        this.updatedAt = LocalDateTime.now();
    }
}
