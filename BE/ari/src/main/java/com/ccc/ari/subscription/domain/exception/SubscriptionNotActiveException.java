package com.ccc.ari.subscription.domain.exception;

import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import lombok.Getter;

@Getter
public class SubscriptionNotActiveException extends SubscriptionException {

    private final SubscriptionId subscriptionId;

    public SubscriptionNotActiveException(SubscriptionId subscriptionId) {
        super(ExceptionCode.SUBSCRIPTION_NOT_ACTIVE,
                String.format("구독(ID: %d)이 활성 상태가 아닙니다.", subscriptionId.getValue()));
        this.subscriptionId = subscriptionId;
    }
}
