package com.ccc.ari.subscription.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
public class ArtistSubscriptionOnChainCreatedEvent {

    private final Integer subscriberId;
    private final Integer artistId;
    private final BigDecimal amount;
}
