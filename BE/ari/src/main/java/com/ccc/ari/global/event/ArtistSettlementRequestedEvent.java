package com.ccc.ari.global.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@AllArgsConstructor
@Builder
public class ArtistSettlementRequestedEvent {

    private final Integer SubscriberId;
    private final Integer ArtistId;
}
