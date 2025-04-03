package com.ccc.ari.subscription.domain;

import com.ccc.ari.subscription.domain.vo.SubscriptionCycleId;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class SubscriptionCycle {

    private final SubscriptionCycleId subscriptionCycleId;

    private final Integer subscriptionId;

    private final LocalDateTime startedAt;

    private final LocalDateTime endedAt;
}
