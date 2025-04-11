package com.ccc.ari.subscription.domain;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.vo.SubscriptionPlanId;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class SubscriptionPlan {

    private final SubscriptionPlanId subscriptionPlanId;
    private final Integer artistId;
    private final PlanType planType;
    private final BigDecimal price;

    @Builder
    public SubscriptionPlan(SubscriptionPlanId subscriptionPlanId,
                            Integer artistId,
                            PlanType planType,
                            BigDecimal price) {
        this.subscriptionPlanId = subscriptionPlanId;
        this.artistId = artistId;
        this.planType = planType;
        this.price = price;
    }
}
