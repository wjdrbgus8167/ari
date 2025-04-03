package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;

public interface SubscriptionCycleRepository {

    void save(SubscriptionCycleEntity subscriptionCycleEntity);
}
