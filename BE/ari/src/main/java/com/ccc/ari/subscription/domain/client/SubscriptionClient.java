package com.ccc.ari.subscription.domain.client;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;

import java.util.List;
import java.util.Optional;

public interface SubscriptionClient {

    // 사용자 ID로 구독 정보 가여오기
    Optional<List<Subscription>> getSubscriptionInfo(Integer memberId);
}
