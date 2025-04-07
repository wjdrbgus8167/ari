package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionCycleEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SubscriptionCycleJpaRepository extends JpaRepository<SubscriptionCycleEntity, Integer> {

    List<SubscriptionCycleEntity> findAllBySubscriptionId(Integer subscriptionId);

    Optional<SubscriptionCycle> findBySubscriptionCycleId(Integer subscriptionCycleId);
}
