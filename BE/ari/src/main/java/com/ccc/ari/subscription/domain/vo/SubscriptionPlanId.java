package com.ccc.ari.subscription.domain.vo;

import lombok.EqualsAndHashCode;

@EqualsAndHashCode
public class SubscriptionPlanId {

    private final Integer subscriptionPlanId;

    public SubscriptionPlanId(Integer subscriptionPlanId) {
        this.subscriptionPlanId = subscriptionPlanId;
    }

    public Integer getValue() {
        return this.subscriptionPlanId;
    }
}
