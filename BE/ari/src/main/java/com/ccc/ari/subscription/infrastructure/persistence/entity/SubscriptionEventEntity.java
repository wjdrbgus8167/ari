package com.ccc.ari.subscription.infrastructure.persistence.entity;

import com.ccc.ari.global.type.PlanType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
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
    @Column(name = "subscriber_id")
    private Integer subscriberId;

    @NotNull
    @Column(name = "plan_type")
    private PlanType planType;

    @Builder
    public SubscriptionEventEntity(String subscriptionEventId,
                                   Integer subscriberId,
                                   PlanType planType) {
        this.subscriptionEventId = subscriptionEventId;
        this.subscriberId = subscriberId;
        this.planType = planType;
    }
}
