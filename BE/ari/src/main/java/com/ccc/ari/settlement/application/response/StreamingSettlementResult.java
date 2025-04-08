package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class StreamingSettlementResult {

    private final Integer artistId;
    private final Integer streaming;
    private final Double amount;
}
