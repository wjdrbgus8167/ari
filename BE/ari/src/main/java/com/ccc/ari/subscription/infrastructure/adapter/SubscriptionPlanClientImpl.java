package com.ccc.ari.subscription.infrastructure.adapter;

import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;


@Component
@RequiredArgsConstructor
public class SubscriptionPlanClientImpl implements SubscriptionPlanClient {

    private final SubscriptionPlanRepository subscriptionPlanRepository;

    @Override
    public SubscriptionPlan getSubscriptionPlan(Integer subscriptionPlanId) {
        return subscriptionPlanRepository.findSubscriptionPlanBySubscriptionPlanId(subscriptionPlanId);
    }

    @Override
    public Optional<SubscriptionPlan> getSubscriptionPlanByArtistId(Integer artistId) {
        return subscriptionPlanRepository.findSubscriptionPlanByArtistId(artistId);
    }
}
