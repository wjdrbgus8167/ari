package com.ccc.ari.subscription.domain;

import com.ccc.ari.subscription.domain.vo.SubscriptionCycleId;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class SubscriptionCycle {

    private final SubscriptionCycleId subscriptionCycleId;
    private final SubscriptionId subscriptionId;
    private final LocalDateTime startedAt;
    private final LocalDateTime endedAt;

    @Builder
    public SubscriptionCycle(SubscriptionCycleId subscriptionCycleId,
                             SubscriptionId subscriptionId,
                             LocalDateTime startedAt,
                             LocalDateTime endedAt) {
        this.subscriptionCycleId = subscriptionCycleId;
        this.subscriptionId = subscriptionId;
        this.startedAt = startedAt;
        this.endedAt = endedAt;
    }

    public static SubscriptionCycle create(SubscriptionId subscriptionId, LocalDateTime startedAt) {
        if(subscriptionId == null) {
            throw new IllegalStateException("구독 ID가 없어 구독 사이클을 생성할 수 없습니다!!");
        }

        return SubscriptionCycle.builder()
                .subscriptionCycleId(null)
                .subscriptionId(subscriptionId)
                .startedAt(startedAt)
                .endedAt(startedAt.plusHours(1))
                .build();
    }

    public void validate() {
        if(endedAt.isBefore(startedAt)) {
            throw new IllegalStateException("구독 사이클의 종료 시간은 시작 시간 이후이어야 합니다!!");
        }
    }
}
