package com.ccc.ari.subscription.domain;

import com.ccc.ari.global.type.PlanType;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class SubscriptionPlan {

    private final Integer artistId;
    private final PlanType planType;
    private final BigDecimal price;
}
