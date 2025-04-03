package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionCycleRepositoryImpl implements SubscriptionCycleRepository {

    private final SubscriptionCycleJpaRepository subscriptionCycleJpaRepository;

    @Override
    public SubscriptionCycle save(SubscriptionCycle subscriptionCycle) {
        return subscriptionCycleJpaRepository.save(SubscriptionCycleEntity.from(subscriptionCycle)).toModel();
    }
}
