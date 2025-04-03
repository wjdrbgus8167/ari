package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionPlanRepository;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionPlanEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {

    private final SubscriptionPlanJpaRepository subscriptionPlanJpaRepository;

    @Override
    public void save(SubscriptionPlanEntity subscriptionPlanEntity) {
        subscriptionPlanJpaRepository.save(subscriptionPlanEntity);
    }

    @Override
    public Optional<SubscriptionPlanEntity> findSubscriptionPlanByPlanType(PlanType planType) {
        return subscriptionPlanJpaRepository.findByPlanType(planType);
    }

    @Override
    public Optional<SubscriptionPlanEntity> findSubscriptionPlanByArtistId(Integer artistId) {
        return subscriptionPlanJpaRepository.findByArtistId(artistId);
    };
}
