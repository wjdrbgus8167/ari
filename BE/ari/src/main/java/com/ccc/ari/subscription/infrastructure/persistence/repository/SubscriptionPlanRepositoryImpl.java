package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
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
    public SubscriptionPlan save(SubscriptionPlan subscriptionPlan) {
        return subscriptionPlanJpaRepository.save(SubscriptionPlanEntity.fromNew(subscriptionPlan)).toModel();
    }

    @Override
    public Optional<SubscriptionPlan> findSubscriptionPlanByPlanType(PlanType planType) {
        return subscriptionPlanJpaRepository.findByPlanType(planType).isPresent() ?
                Optional.of(subscriptionPlanJpaRepository.findByPlanType(planType).get().toModel()) :
                Optional.empty();
    }

    @Override
    public Optional<SubscriptionPlan> findSubscriptionPlanByArtistId(Integer artistId) {
        return subscriptionPlanJpaRepository.findByArtistId(artistId).isPresent() ?
                Optional.of(subscriptionPlanJpaRepository.findByArtistId(artistId).get().toModel()) :
                Optional.empty();
    }

    @Override
    public SubscriptionPlan findSubscriptionPlanBySubscriptionPlanId(Integer subscriptionPlanId) {
        SubscriptionPlanEntity entity = subscriptionPlanJpaRepository.findById(subscriptionPlanId)
                .orElseThrow(()->new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));
        return entity.toModel();
    }


}
