package com.ccc.ari.community.application.rating.commad;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class CreateAlbumRatingCommand {
    private Integer memberId;
    private Integer albumId;
    private BigDecimal rating;
}
