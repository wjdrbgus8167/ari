package com.ccc.ari.subscription.ui.client;

import com.ccc.ari.subscription.application.service.SubscriptionQueryService;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class SubscriptionClient {

    private final SubscriptionQueryService subscriptionQueryService;

    public SubscriptionCycle getRegularSubscriptionCycleIdByPeriod(Integer subscriberId,
                                                                   LocalDateTime startTime, LocalDateTime endTime) {
        return subscriptionQueryService.getRegularSubscriptionCycleByPeriod(subscriberId, startTime, endTime);
    }

    public SubscriptionCycle getArtistSubscriptionCycleIdByPeriod(Integer subscriberId, Integer artistId,
                                                                   LocalDateTime startTime, LocalDateTime endTime) {
        return subscriptionQueryService.getArtistSubscriptionCycleIdByPeriod(subscriberId, artistId, startTime, endTime);
    }

    public SubscriptionCycle getSubscriptionCycleById(Integer subscriptionCycleId) {
        return subscriptionQueryService.getSubscriptionCycleById(subscriptionCycleId);
    }
}
