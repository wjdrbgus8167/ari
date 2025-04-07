package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.Subscription;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface SubscriptionClient {

    // 사용자 ID로 구독 정보 가여오기
    Optional<List<Subscription>> getSubscriptionInfo(Integer memberId);

    // 구독플랜Id로 구독 정보 조회
    List<Subscription> getSubscriptionBySubscriptionPlanId(Integer subscriptionPlanId);

    // 이번달에 구독목록 조회
    List<Subscription> getRegularSubscription(Integer subscriptionPlanId,LocalDateTime start, LocalDateTime end);

    Optional<Subscription> getSubscription(Integer subscriptionId);
}
