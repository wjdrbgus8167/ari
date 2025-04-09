package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class CycleSettlementInfo {

    private final Integer CycleId;
    private final Double Settlement;
}
