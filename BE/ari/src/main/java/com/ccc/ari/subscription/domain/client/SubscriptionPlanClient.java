package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.SubscriptionPlan;

public interface SubscriptionPlanClient {

    SubscriptionPlan getSubscriptionPlan(Integer subscriptionPlanId);
}
