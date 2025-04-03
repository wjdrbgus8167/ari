package com.ccc.ari.subscription.infrastructure.persistence.entity;


import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.vo.SubscriptionCycleId;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "subscription_cycles")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class SubscriptionCycleEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "subscription_cycle_id")
    private Integer subscriptionCycleId;

    @NotNull
    @Column(name = "subscription_id")
    private Integer subscriptionId;

    @NotNull
    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @NotNull
    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Builder
    public SubscriptionCycleEntity(Integer subscriptionCycleId,
                                   Integer subscriptionId,
                                   LocalDateTime startedAt,
                                   LocalDateTime endedAt) {
        this.subscriptionCycleId = subscriptionCycleId;
        this.subscriptionId = subscriptionId;
        this.startedAt = startedAt;
        this.endedAt = endedAt;
    }

    // from 엔터티 to 도메인 모델
    public SubscriptionCycle toModel() {
        return SubscriptionCycle.builder()
                .subscriptionCycleId(new SubscriptionCycleId(subscriptionCycleId))
                .subscriptionId(subscriptionId)
                .startedAt(startedAt)
                .endedAt(endedAt)
                .build();
    }

    // from 도메인 모델 to 엔터티
    public static SubscriptionCycleEntity from(SubscriptionCycle subscriptionCycle) {
        return SubscriptionCycleEntity.builder()
                .subscriptionCycleId(subscriptionCycle.getSubscriptionCycleId().getValue())
                .subscriptionId(subscriptionCycle.getSubscriptionId())
                .startedAt(subscriptionCycle.getStartedAt())
                .endedAt(subscriptionCycle.getEndedAt())
                .build();
    }
}
