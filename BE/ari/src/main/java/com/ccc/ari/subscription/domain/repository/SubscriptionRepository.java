package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.subscription.domain.Subscription;

import java.util.List;
import java.util.Optional;

public interface SubscriptionRepository {

    Subscription save(Subscription subscription);

    /**
     * 활성화된 특정 멤버의 특정 구독 플랜의 구독을 조회합니다.
     *
     * @param memberId 조회할 멤버 ID
     * @param subscriptionPlanId 조회할 구독 플랜 ID
     */
    Optional<Subscription> findActiveSubscription(Integer memberId, Integer subscriptionPlanId);

    Optional<Subscription> findBySubscriptionId(Integer subscriptionId);

    Optional<List<Subscription>> findListByMemberId(Integer memberId);
}
