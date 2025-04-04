package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.global.type.PlanType;

public interface SubscriptionEventRepository {

    boolean existsBySubscriptionEventId(String subscriptionEventId);

    void save(String subscriptionEventId, Integer subscriberId, PlanType eventType);
}
