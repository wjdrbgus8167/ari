package com.ccc.ari.global.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@AllArgsConstructor
@Builder
public class RegularSettlementRequestedEvent {

    private final Integer subscriberId;
}
