package com.ccc.ari.subscription.domain.exception;

import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import lombok.Getter;

@Getter
public class SubscriptionNotFoundException extends SubscriptionException {

    private final SubscriptionId subscriptionId;

    public SubscriptionNotFoundException(SubscriptionId subscriptionId) {
        super(ExceptionCode.SUBSCRIPTION_NOT_FOUND,
                String.format("구독(ID: %d)을 찾을 수 없습니다.", subscriptionId.getValue()));
        this.subscriptionId = subscriptionId;
    }
}
