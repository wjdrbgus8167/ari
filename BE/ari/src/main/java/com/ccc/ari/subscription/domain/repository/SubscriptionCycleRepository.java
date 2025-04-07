package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

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

    /**
     * 특정 기간에 속한 특정 구독의 구독 사이클을 가져옵니다.
     */
    Optional<SubscriptionCycle> getSubscriptionCycleByPeriod(SubscriptionId subscriptionId,
                                                             LocalDateTime startTime, LocalDateTime endTime);
}
