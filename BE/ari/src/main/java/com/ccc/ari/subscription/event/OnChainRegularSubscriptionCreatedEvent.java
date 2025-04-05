package com.ccc.ari.subscription.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
public class OnChainRegularSubscriptionCreatedEvent {

    private final Integer subscriberId;
    private final BigDecimal amount;
}
