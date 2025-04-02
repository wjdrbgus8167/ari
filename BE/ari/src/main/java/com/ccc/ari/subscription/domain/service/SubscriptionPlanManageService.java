package com.ccc.ari.subscription.domain.service;

import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.infrastructure.persistence.entity.PlanType;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class SubscriptionPlanManageService {

    /**
     * 정기 구독 SubscriptionPlan을 생성합니다.
     * 이 메서드는 artistId와 artistNickname을 null로 초기화하여 SubscriptionPlan을 생성합니다.
     *
     * @param price    구독 플랜의 가격
     * @return 지정된 플랜 유형과 가격을 가진 새로운 SubscriptionPlan 객체
     */
    public SubscriptionPlan createRegularSubscriptionPlan(BigDecimal price) {
        return SubscriptionPlan.builder()
                .artistId(null)
                .planType(PlanType.R)
                .price(price)
                .build();
    }

    /**
     * 지정된 플랜 유형, 아티스트 ID, 아티스트 닉네임 및 가격으로 아티스트 SubscriptionPlan을 생성합니다.
     *
     * @param artistId       아티스트의 ID
     * @param price          구독 플랜의 가격
     * @return 지정된 속성을 가진 새로운 SubscriptionPlan 객체
     */
    public SubscriptionPlan createArtistSubscriptionPlan(Integer artistId, BigDecimal price) {
        return SubscriptionPlan.builder()
                .planType(PlanType.A)
                .artistId(artistId)
                .price(price)
                .build();
    }

    // TODO: 구독 플랜의 가격을 변경하는 메소드를 추후 구현하겠습니다.
}
