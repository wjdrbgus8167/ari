package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.SubscriptionPlan;

import java.util.Optional;

public interface SubscriptionPlanClient {

    SubscriptionPlan getSubscriptionPlan(Integer subscriptionPlanId);

    Optional<SubscriptionPlan> getSubscriptionPlanByArtistId(Integer artistId);
}
