package com.ccc.ari.subscription.application.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import org.jetbrains.annotations.NotNull;

public interface SubscriptionRepository {

    public void save(SubscriptionEntity subscriptionEntity);
}
