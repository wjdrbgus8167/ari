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

    /**
     * 특정 사용자의 특정 구독 플랜에 대한 모든 구독 목록을 조회합니다.
     * (활성화, 비활성화 모두)
     */
    Optional<List<Subscription>> findListByMemberIdAndSubscriptionPlanId(Integer memberId, Integer subscriptionPlanId);
}
