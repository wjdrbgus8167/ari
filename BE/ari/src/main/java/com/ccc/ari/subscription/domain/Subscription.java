package com.ccc.ari.subscription.domain;

import com.ccc.ari.subscription.domain.exception.SubscriptionNotActiveException;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
public class Subscription {

    private final SubscriptionId subscriptionId;
    private final Integer memberId;
    private final Integer subscriptionPlanId;
    private final LocalDateTime subscribedAt;
    private LocalDateTime expiredAt;
    private final boolean activateYn;
    private List<SubscriptionCycle> cycles;

    @Builder
    public Subscription(SubscriptionId subscriptionId,
                        Integer memberId,
                        Integer subscriptionPlanId,
                        LocalDateTime subscribedAt,
                        boolean activateYn,
                        LocalDateTime expiredAt) {
        this.subscriptionId = subscriptionId;
        this.memberId = memberId;
        this.subscriptionPlanId = subscriptionPlanId;
        this.subscribedAt = subscribedAt;
        this.activateYn = activateYn;
        this.expiredAt = expiredAt;
        this.cycles = new ArrayList<>();
    }

    public SubscriptionCycle startFirstCycle() {
        validateCanStartNewCycle();
        SubscriptionCycle firstCycle = SubscriptionCycle.create(this.subscriptionId, LocalDateTime.now());
        cycles.add(firstCycle);
        return firstCycle;
    }

    public SubscriptionCycle startNewCycle(SubscriptionCycle latestCycle) {
        validateCanStartNewCycle();
        // 1 마이크로 초 이후로 사이클 시작 설정
        SubscriptionCycle newCycle = SubscriptionCycle.create(this.subscriptionId,
                                                              latestCycle.getEndedAt().plusNanos(1000));
        cycles.add(newCycle);
        return newCycle;
    }

    private void validateCanStartNewCycle() {
        if (!activateYn) {
            throw new SubscriptionNotActiveException(this.subscriptionId);
        }
    }
}
