package com.ccc.ari.subscription.domain.vo;

import lombok.EqualsAndHashCode;
import lombok.Getter;

@EqualsAndHashCode
public class SubscriptionCycleId {

    private final Integer subscriptionCycleId;

    public SubscriptionCycleId(Integer subscriptionCycleId) {
        this.subscriptionCycleId = subscriptionCycleId;
    }

    public Integer getValue() {
        return this.subscriptionCycleId;
    }
}
