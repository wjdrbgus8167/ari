package com.ccc.ari.subscription.infrastructure.persistence.entity;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.vo.SubscriptionPlanId;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "subscription_plans")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class SubscriptionPlanEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "subscription_plan_id")
    private Integer subscriptionPlanId;

    @Column(nullable = true, name = "artist_id")
    private Integer artistId;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "plan_type")
    private PlanType planType;

    @NotNull
    @Column(name = "price")
    private BigDecimal price;

    @Builder
    public SubscriptionPlanEntity(Integer subscriptionPlanId,
                                  Integer artistId,
                                  PlanType planType,
                                  BigDecimal price) {
        this.subscriptionPlanId = subscriptionPlanId;
        this.artistId = artistId;
        this.planType = planType;
        this.price = price;
    }

    // from 엔터티 to 도메인 모델
    public SubscriptionPlan toModel() {
        return SubscriptionPlan.builder()
                .subscriptionPlanId(new SubscriptionPlanId(subscriptionPlanId))
                .artistId(artistId)
                .planType(planType)
                .price(price)
                .build();
    }

    // from 새롭게 생성한 도메인 모델 to 엔터티
    public static SubscriptionPlanEntity fromNew(SubscriptionPlan subscriptionPlan) {
        return SubscriptionPlanEntity.builder()
                .subscriptionPlanId(null)
                .artistId(subscriptionPlan.getArtistId())
                .planType(subscriptionPlan.getPlanType())
                .price(subscriptionPlan.getPrice())
                .build();
    }

    // from 존재하던 도메인 모델 to 엔터티
    public static SubscriptionPlanEntity fromExisting(SubscriptionPlan subscriptionPlan) {
        return SubscriptionPlanEntity.builder()
                .subscriptionPlanId(subscriptionPlan.getSubscriptionPlanId().getValue())
                .artistId(subscriptionPlan.getArtistId())
                .planType(subscriptionPlan.getPlanType())
                .price(subscriptionPlan.getPrice())
                .build();
    }
}
