package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;

import java.util.List;

public interface SubscriptionCycleRepository {

    SubscriptionCycle save(SubscriptionCycle subscriptionCycle);

    /**
     * 해당 구독의 가장 최근 구독 사이클을 가져옵니다.
     */
    SubscriptionCycle getLatestCycle(SubscriptionId subscriptionId);

    /**
     * 구독 ID로 해당 구독의 모든 구독 사이클을 가져옵니다.
     */
    List<SubscriptionCycle> getSubscriptionCycleList(SubscriptionId subscriptionId);
}
