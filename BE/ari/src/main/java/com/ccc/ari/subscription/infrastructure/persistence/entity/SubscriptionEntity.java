package com.ccc.ari.subscription.infrastructure.persistence.entity;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import lombok.Getter;
import lombok.Builder;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDateTime;

@Entity
@Table(name = "subscriptions")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class SubscriptionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "subscription_id")
    private Integer subscriptionId;

    @NotNull
    @Column(name = "member_id")
    private Integer memberId;

    @NotNull
    @Column(name = "subscription_plan_id")
    private Integer subscriptionPlanId;

    @NotNull
    @Column(name = "subscribed_at")
    private LocalDateTime subscribedAt;

    @Column(nullable = true, name = "expired_at")
    private LocalDateTime expiredAt;

    @NotNull
    @Column(name = "activate_yn")
    @ColumnDefault("true")
    private boolean activateYn;

    @Builder
    public SubscriptionEntity(Integer subscriptionId,
                              Integer memberId,
                              Integer subscriptionPlanId,
                              LocalDateTime subscribedAt,
                              LocalDateTime expiredAt,
                              boolean activateYn) {
        this.subscriptionId = subscriptionId;
        this.memberId = memberId;
        this.subscriptionPlanId = subscriptionPlanId;
        this.subscribedAt = subscribedAt;
        this.expiredAt = expiredAt;
        this.activateYn = activateYn;
    }

    // from 엔터티 to 도메인 모델
    public Subscription toModel() {
        return Subscription.builder()
                .subscriptionId(new SubscriptionId(subscriptionId))
                .memberId(memberId)
                .subscriptionPlanId(subscriptionPlanId)
                .subscribedAt(subscribedAt)
                .activateYn(activateYn)
                .build();
    }

    // from 새롭게 생성한 도메인 모델 to 엔터티
    public static SubscriptionEntity fromNew(Subscription subscription) {
        return SubscriptionEntity.builder()
                .subscriptionId(null)
                .memberId(subscription.getMemberId())
                .subscriptionPlanId(subscription.getSubscriptionPlanId())
                .subscribedAt(subscription.getSubscribedAt())
                .expiredAt(subscription.getExpiredAt())
                .activateYn(subscription.isActivateYn())
                .build();
    }
    // from 존재하던 도메인 모델 to 엔터티
    public static SubscriptionEntity fromExisting(Subscription subscription) {
        return SubscriptionEntity.builder()
                .subscriptionId(subscription.getSubscriptionId().getValue())
                .memberId(subscription.getMemberId())
                .subscriptionPlanId(subscription.getSubscriptionPlanId())
                .subscribedAt(subscription.getSubscribedAt())
                .expiredAt(subscription.getExpiredAt())
                .activateYn(subscription.isActivateYn())
                .build();
    }
}
