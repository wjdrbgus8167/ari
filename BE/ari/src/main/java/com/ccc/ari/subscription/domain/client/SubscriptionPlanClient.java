package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.SubscriptionPlan;

import java.util.List;
import java.util.Optional;

public interface SubscriptionPlanClient {

    SubscriptionPlan getSubscriptionPlan(Integer subscriptionPlanId);

    SubscriptionPlan getSubscriptionPlanByArtistId(Integer artistId);
}
