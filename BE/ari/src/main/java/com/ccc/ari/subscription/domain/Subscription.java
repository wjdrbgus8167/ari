package com.ccc.ari.subscription.domain;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Subscription {

    private final Integer memberId;
    private final Integer subscriptionPlanId;
    private final LocalDateTime subscribedAt;
    private LocalDateTime expiredAt;
    private boolean activateYn;

    @Builder
    public Subscription(Integer memberId,
                        Integer subscriptionPlanId,
                        LocalDateTime subscribedAt,
                        boolean activateYn) {
        this.memberId = memberId;
        this.subscriptionPlanId = subscriptionPlanId;
        this.subscribedAt = subscribedAt;
        this.activateYn = activateYn;
    }
}
