package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;

import java.util.List;

public interface SubscriptionCycleClient {

    List<SubscriptionCycle> getSubscriptionCycle(SubscriptionId subscriptionId);
}
