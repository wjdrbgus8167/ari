package com.ccc.ari.subscription.infrastructure.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {

    private final SubscriptionPlanJpaRepository subscriptionPlanJpaRepository;
}
