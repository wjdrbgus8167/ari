package com.ccc.ari.subscription.domain.vo;

import lombok.EqualsAndHashCode;

@EqualsAndHashCode
public class SubscriptionId {

    private final Integer subscriptionId;

    public SubscriptionId(Integer subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

    public Integer getValue() {
        return this.subscriptionId;
    }
}
