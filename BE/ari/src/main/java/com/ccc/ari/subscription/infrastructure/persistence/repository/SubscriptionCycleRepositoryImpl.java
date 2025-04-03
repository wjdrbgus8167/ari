package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionCycleRepositoryImpl implements SubscriptionCycleRepository {

    private SubscriptionCycleJpaRepository subscriptionCycleJpaRepository;

    @Override
    public void save(SubscriptionCycleEntity subscriptionCycleEntity) {
        subscriptionCycleJpaRepository.save(subscriptionCycleEntity);
    }
}
