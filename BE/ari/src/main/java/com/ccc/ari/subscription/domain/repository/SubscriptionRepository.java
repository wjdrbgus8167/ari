package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;

import java.util.Optional;

public interface SubscriptionRepository {

    public void save(SubscriptionEntity subscriptionEntity);

    /**
     * 활성화된 특정 멤버의 특정 구독 플랜의 구독을 조회합니다.
     *
     * @param memberId 조회할 멤버 ID
     * @param subscriptionPlanId 조회할 구독 플랜 ID
     */
    public Optional<SubscriptionEntity> findActiveSubscription(Integer memberId, Integer subscriptionPlanId);
}
