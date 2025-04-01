package com.ccc.ari.subscription.infrastructure.repository;

import com.ccc.ari.subscription.infrastructure.entity.SubscriptionPlanEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubscriptionPlanJpaRepository extends JpaRepository<SubscriptionPlanEntity, Integer> {
}
