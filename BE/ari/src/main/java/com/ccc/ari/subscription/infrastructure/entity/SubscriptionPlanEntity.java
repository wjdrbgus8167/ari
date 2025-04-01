package com.ccc.ari.subscription.infrastructure.entity;

import com.ccc.ari.subscription.domain.SubscriptionPlan;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "subscription_plan")
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

    @Column(nullable = true, name = "artist_nickname")
    private String artistNickname;

    @Builder
    public SubscriptionPlanEntity(Integer subscriptionPlanId,
                                  Integer artistId,
                                  PlanType planType,
                                  BigDecimal price,
                                  String artistNickname) {
        this.subscriptionPlanId = subscriptionPlanId;
        this.artistId = artistId;
        this.planType = planType;
        this.price = price;
        this.artistNickname = artistNickname;
    }

    // from 엔터티 to 도메인 모델
    public SubscriptionPlan toModel() {
        return SubscriptionPlan.builder()
                .artistId(artistId)
                .planType(planType)
                .price(price)
                .artistNickname(artistNickname)
                .build();
    }

    // from 도메인 모델 to 엔터티
    public static SubscriptionPlanEntity from(SubscriptionPlan subscriptionPlan) {
        return SubscriptionPlanEntity.builder()
                .artistId(subscriptionPlan.getArtistId())
                .planType(subscriptionPlan.getPlanType())
                .price(subscriptionPlan.getPrice())
                .artistNickname(subscriptionPlan.getArtistNickname())
                .build();
    }
}
