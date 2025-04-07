package com.ccc.ari.subscription.infrastructure.persistence.entity;

import com.ccc.ari.global.type.EventType;
import com.ccc.ari.global.type.PlanType;
import jakarta.annotation.Nullable;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "subscription_events")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class SubscriptionEventEntity {

    @Id
    @Column(name = "subscription_event_id")
    private String subscriptionEventId;

    @NotNull
    @Enumerated(EnumType.STRING)
    private EventType eventType;

    @NotNull
    @Column(name = "subscriber_id")
    private Integer subscriberId;

    @Nullable
    @Column(name = "plan_type")
    private PlanType planType;

    @Builder
    public SubscriptionEventEntity(String subscriptionEventId,
                                   EventType eventType,
                                   Integer subscriberId,
                                   PlanType planType) {
        this.subscriptionEventId = subscriptionEventId;
        this.eventType = eventType;
        this.subscriberId = subscriberId;
        this.planType = planType;
    }
}