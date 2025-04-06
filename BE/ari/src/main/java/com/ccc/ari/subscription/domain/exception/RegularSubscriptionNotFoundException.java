package com.ccc.ari.subscription.domain.exception;

public class RegularSubscriptionNotFoundException extends SubscriptionException {
    public RegularSubscriptionNotFoundException() {
        super(ExceptionCode.REGULAR_SUBSCRIPTION_NOT_FOUND,
                "사용자의 정기 구독이 존재하지 않습니다!!");
    }
}
