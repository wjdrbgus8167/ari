package com.ccc.ari.community.infrastructure.rating.adapter;

import com.ccc.ari.community.application.rating.service.RatingService;
import com.ccc.ari.community.domain.rating.client.RatingClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class RatingClientImpl implements RatingClient {

    private final RatingService ratingService;

    @Override
    public BigDecimal getRating(Integer albumId) {

        return ratingService.getRating(albumId);
    }
}
