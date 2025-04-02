package com.ccc.ari.community.domain.rating.client;

import java.math.BigDecimal;

public interface RatingClient {
    BigDecimal getRating(Integer albumId);
}
