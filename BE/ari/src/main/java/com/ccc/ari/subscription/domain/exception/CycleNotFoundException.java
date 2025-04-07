package com.ccc.ari.subscription.domain.exception;

import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class CycleNotFoundException extends SubscriptionException {

    private final LocalDateTime startTime;
    private final LocalDateTime endTime;

    public CycleNotFoundException(LocalDateTime startTime, LocalDateTime endTime) {
        super(ExceptionCode.CYCLE_NOT_FOUND,
                String.format("기간(%s ~ %s) 동안의 구독 사이클을 찾을 수 없습니다",
                        startTime, endTime));
        this.startTime = startTime;
        this.endTime = endTime;
    }
}
