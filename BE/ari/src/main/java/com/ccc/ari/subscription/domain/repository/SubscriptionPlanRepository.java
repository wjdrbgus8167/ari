package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.SubscriptionPlan;

import java.util.Optional;

public interface SubscriptionPlanRepository {

    /**
     * 구독 플랜 엔터티를 저장합니다.
     *
     * @param subscriptionPlan 저장할 구독 플랜 도메인 객체
     * @throws IllegalArgumentException subscriptionPlanEntity가 null인 경우
     */
    public void save(SubscriptionPlan subscriptionPlan);

    /**
     * 구독 플랜 엔터티 타입으로 구독 플랜 엔터티를 조회합니다.
     *
     * @param planType 조회할 구독 플랜 타입 (R또는 A)
     * @return 해당 플랜 타입의 구독 플랜, 없을 경우 빈 Optional
     * @throws IllegalArgumentException planType이 null인 경우
     */
    public Optional<SubscriptionPlan> findSubscriptionPlanByPlanType(PlanType planType);

    /**
     * 아티스트 ID로 구독 플랜 엔터티를 조회합니다.
     *
     * @param artistId 조회할 아티스트 ID
     * @return 해당 아티스트 ID의 구독 플랜, 없을 경우 빈 Optional
     * @throws IllegalArgumentException artistId가 null인 경우
     */
    public Optional<SubscriptionPlan> findSubscriptionPlanByArtistId(Integer artistId);

    SubscriptionPlan findSubscriptionPlanBySubscriptionPlanId(Integer subscriptionPlanId);
}
