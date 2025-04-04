package com.ccc.ari.subscription.domain.exception;

import lombok.Getter;

@Getter
public class RegularPlanNotFoundException extends SubscriptionException {

    public RegularPlanNotFoundException() {
        super(ExceptionCode.REGULAR_PLAN_NOT_FOUND,
                "정기 구독 플랜이 존재하지 않습니다!!");
    }
}
