package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;

import java.util.List;
import java.util.Optional;

public interface SubscriptionCycleClient {

    List<SubscriptionCycle> getSubscriptionCycle(SubscriptionId subscriptionId);
    SubscriptionCycle getLatestSubscriptionCycle(SubscriptionId subscriptionId);
}
