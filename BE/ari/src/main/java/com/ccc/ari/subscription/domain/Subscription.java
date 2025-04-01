package com.ccc.ari.subscription.domain;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class Subscription {

    private final Integer memberId;
    private final Integer subscriptionPlanId;
    private final LocalDateTime subscribedAt;
    private LocalDateTime expiredAt;
    private boolean activateYn;
}
