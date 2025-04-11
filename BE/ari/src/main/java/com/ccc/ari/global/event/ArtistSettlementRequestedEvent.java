package com.ccc.ari.global.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigInteger;

@Getter
@AllArgsConstructor
@Builder
public class ArtistSettlementRequestedEvent {

    private final Integer SubscriberId;
    private final Integer ArtistId;
    private final BigInteger PeriodStart;
    private final BigInteger PeriodEnd;
}
