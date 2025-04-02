package com.ccc.ari.community.ui.rating.request;

import com.ccc.ari.community.application.rating.commad.CreateAlbumRatingCommand;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@NoArgsConstructor
public class CreatAlbumRatingRequest {

    private String rating;

    public CreateAlbumRatingCommand toCommand(Integer memberId, Integer albumId){

        return CreateAlbumRatingCommand.builder()
                .memberId(memberId)
                .albumId(albumId)
                .rating(new BigDecimal(rating).setScale(1))
                .build();
    }

}
