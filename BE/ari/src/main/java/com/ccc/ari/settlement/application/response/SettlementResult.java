package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class SettlementResult {

    private final Integer subscriberId;
    private final Integer artistId;
    private final Integer cycleId;
    private final Integer amount;
}
