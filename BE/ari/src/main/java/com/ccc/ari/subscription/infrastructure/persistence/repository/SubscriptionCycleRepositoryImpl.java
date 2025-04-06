package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Comparator;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class SubscriptionCycleRepositoryImpl implements SubscriptionCycleRepository {

    private final SubscriptionCycleJpaRepository subscriptionCycleJpaRepository;

    private static final Comparator<SubscriptionCycleEntity> LATEST_CYCLE_COMPARATOR =
            Comparator.comparing(SubscriptionCycleEntity::getEndedAt);

    @Override
    public SubscriptionCycle save(SubscriptionCycle subscriptionCycle) {
        return subscriptionCycleJpaRepository.save(SubscriptionCycleEntity.from(subscriptionCycle)).toModel();
    }

    @Override
    public SubscriptionCycle getLatestCycle(SubscriptionId subscriptionId) {
        return subscriptionCycleJpaRepository.findAllBySubscriptionId(subscriptionId.getValue())
                .stream()
                .max(LATEST_CYCLE_COMPARATOR)
                .map(SubscriptionCycleEntity::toModel)
                .orElse(null);
    }

    @Override
    public List<SubscriptionCycle> getSubscriptionCycleList(SubscriptionId subscriptionId) {
        return subscriptionCycleJpaRepository.findAllBySubscriptionId(subscriptionId.getValue())
                .stream()
                .map(SubscriptionCycleEntity::toModel)
                .toList();
    }
}
