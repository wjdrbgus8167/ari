package com.ccc.ari.global.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigInteger;

@Getter
@AllArgsConstructor
@Builder
public class RegularSettlementRequestedEvent {

    private final Integer subscriberId;
    private final BigInteger periodStart;
    private final BigInteger periodEnd;
}
