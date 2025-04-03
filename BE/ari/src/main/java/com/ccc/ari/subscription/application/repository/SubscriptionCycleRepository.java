package com.ccc.ari.subscription.application.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;

public interface SubscriptionCycleRepository {

    void save(SubscriptionCycleEntity subscriptionCycleEntity);
}
