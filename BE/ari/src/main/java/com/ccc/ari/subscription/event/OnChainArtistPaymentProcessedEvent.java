package com.ccc.ari.subscription.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class OnChainArtistPaymentProcessedEvent {

    private final Integer subscriberId;
    private final Integer artistId;
}
